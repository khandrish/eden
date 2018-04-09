defmodule Exmud.Engine.Script do
  @moduledoc """
  Scripts perform repeated logic on Objects within the game world.

  Examples include a character slowly drying off, a wound draining vitality, an opened door automatically closing, and
  so on. They can control longer running logic such as AI behaviors that are meant to remain on the Object permanently,
  and shorter one off tasks where the script will be removed after a single run.

  While Scripts are attached to a single Object, there is no restriction on the data a Script can modify. It is up to
  the implementor to play nice with the rest of the system.

  While each Script instance has its own state, please note that this state is only for that data which helps the Script
  itself run, and should not be used to store any data expected to be used/accessed by any other entity within the
  system.
  """


  @doc false
  defmacro __using__(_) do
    quote location: :keep do

      @behaviour Exmud.Engine.Script

      @doc false
      def handle_message(_object_id, message, state), do: {:ok, message, state}

      @doc false
      def initialize(_object_id, _args), do: {:ok, nil}

      @doc false
      def name, do: Atom.to_string(__MODULE__)

      @doc false
      def run(_object_id, state), do: {:ok, state}

      @doc false
      def start(_object_id, _args, state), do: {:ok, state, 0}

      @doc false
      def stop(_object_id, _reason, state), do: {:ok, state}

      defoverridable [handle_message: 3,
                      initialize: 2,
                      name: 0,
                      run: 2,
                      start: 3,
                      stop: 3]
    end
  end


  #
  # Behavior definition and default callback setup
  #


  @doc """
  Handle a message which has been explicitly sent to the Script.
  """
  @callback handle_message(object_id, message, state) :: {:ok, reply, state} | {:error, reason}

  @doc """
  Called the first, and only the first, time a Script is started on an Object. Or in the case of duplicate Scripts, once
  per Script Name/Dedupe Key combination.

  If called, it will immediately precede `start/2` and the returned state will be passed to the `start/2` callback.
  If a Script has been previously initialized, the persisted state is loaded from the database and used in the `start/2`
  callback instead.
  """
  @callback initialize(object_id, args) :: {:ok, state} | {:error, reason}

  @doc """
  Called in response to an interval period expiring, or an explicit call to run the Script again. Unlike Systems, a
  Script is always expected to be running.
  """
  @callback run(object_id, state) :: {:ok, state} |
                                     {:ok, state, next_iteration} |
                                     {:stop, reason, state} |
                                     {:error, error, state} |
                                     {:error, error, state, next_iteration}

  @doc """
  Called when the Script is being started.

  If this is the first time the Script has been started it will immediately follow a call to 'initialize/2' and will be
  called with the state returned from the previous call, otherwise the state will be loaded from the database and used
  instead. Must return a new state.
  """
  @callback start(object_id,args, state) :: {:ok, state, next_iteration} | {:error, error, state}

  @doc """
  Called when the system is being stopped.

  Must return a new state which will be persisted.
  """
  @callback stop(object_id, args, state) :: {:ok, state} | {:error, error, state}

  @typedoc "Arguments passed through to a callback module."
  @type args :: term

  @typedoc "A message passed through to a callback module."
  @type message :: term

  @typedoc "How many milliseconds should pass until the run callback is called again."
  @type next_iteration :: integer

  @typedoc "A reply passed through to the caller."
  @type reply :: term

  @typedoc "An error message passed through to the caller."
  @type error :: term

  @typedoc "The reason the System is stopping."
  @type reason :: term

  @typedoc "State used by the callback module."
  @type state :: term

  @typedoc "Id of an Object."
  @type object_id :: term

  alias Exmud.Engine.Cache
  alias Exmud.Engine.Repo
  alias Exmud.Engine.Schema.Script
  require Logger
  import Ecto.Query
  import Exmud.Common.Utils
  import Exmud.Engine.Utils

  @script_registry script_registry()


  #
  # Manipulation of a single Script on an Object
  #


  @doc """
  Call a running Script with a message.
  """
  def call(object_id, name, message) do
    send_message(:call, object_id, name, {:message, message})
  end

  @doc """
  Cast a message to a running Script.
  """
  def cast(object_id, name, message) do
    send_message(:cast, object_id, name, {:message, message})
  end

  @doc """
  Detach a Script from an Object.

  This method first stops the Script if it is running before moving on to removing the Script from the database. It is
  also destructive, with the state of the Script being destroyed at the time of removal.
  """
  def detach(object_id, name) do
    stop(object_id, name)
    script_query(object_id, name)
    |> Repo.delete_all()
    |> case do
      {1, _} ->   :ok
      {0, _} -> {:error, :script_not_removed}
    end
  end

  @doc """
  Get the state of a Script.

  First the running Script will be queried for the state, and then the database. Only if both fail to return a result is
  an error returned.
  """
  def get_state(object_id, name) do
    try do
      GenServer.call(via(@script_registry, {object_id, name}), :state, :infinity)
    catch
      :exit, {:noproc, _} ->
        script_query(object_id, name)
        |> Repo.one()
        |> case do
          nil -> {:error, :no_such_script}
          script ->
            {:ok, unpack_term(script.state)}
        end
    end
  end

  @doc """
  Check to see if a Script is attached to an Object.
  """
  def is_attached?(object_id, name) do
    query =
      from script in script_query(object_id, name),
        select: count("*")

    Repo.one(query) == 1
  end

  @doc """
  Purge Script data from the database.

  This method does not checking for a running Script, or in any way ensure that the data can't or won't be rewritten. It
  is a dumb delete.
  """
  def purge(object_id, name) do
    script_query(object_id, name)
    |> Repo.one()
    |> case do
      nil -> {:error, :no_such_script}
      script ->
        {:ok, _} = Repo.delete(script)
        :ok
    end
  end

  @doc """
  Trigger a Script to run immediately. If a Script is running while this call is made the Script will run again as soon
  as it can.

  This method ensures that the Script is active and that it will begin the process of running its main loop immediately,
  but offers no other guarantees.
  """
  def run(object_id, name) do
    send_message(:call, object_id, name, :run)
  end

  @doc """
  Check to see if a Script is running on an Object.

  This method is not for checking if the Script is running its main loop at that moment, but to check if it is still
  active or if it is currently stopped. If there is no Script running matching the provided parameters, it does not
  check the database to validate that such a Script actively exists. To check if an Object has a Script attached to it,
  see the 'has?/2' method.
  """
  def running?(object_id, name) do
    result = Registry.lookup(@script_registry, {object_id, name})
    result != []
  end

  @doc """
  Start a Script on an object. This works for both attaching a new Script to an Object and restarting an existing
  Script.
  """
  def start(object_id, name, args \\ nil) do
    with {:ok, _} <- Supervisor.start_child(Exmud.Engine.ScriptRunnerSupervisor, [object_id, name, args])
    do
      :ok
    end
  end

  @doc """
  Stops a Script if it is started.
  """
  def stop(object_id, name, args \\ nil) do
    send_message(:call, object_id, name, {:stop, args})
  end

  @doc """
  Update the state of a Script in the database.

  Primarily used by the Engine to persiste the state of a running Script whenever it changes.
  """
  def update(object_id, script_name, state) do
    query =
      from script in Script,
        where: script.object_id == ^object_id and script.name == ^script_name

    case Repo.update_all(Script, set: [state: pack_term(state)]) do
      {1, _} -> :ok
      _ -> {:error, :no_such_script}
    end
  end


  #
  # Manipulation of Scripts in the Engine.
  #


  @cache :script_cache

  @doc """
  List all Scripts which have been registered with the engine since the last start.
  """
  def list_registered() do
    Logger.info("Listing all registered Scripts")
    Cache.list(@cache)
  end

  @doc """
  Lookup the callback module for the Script with the provided name.
  """
  def lookup(name) do
    case Cache.get(@cache, name) do
      {:error, _} ->
        Logger.error("Lookup failed for Script registered with name `#{name}`")
        {:error, :no_such_script}
      result ->
        Logger.info("Lookup succeeded for Script registered with name `#{name}`")
        result
    end
  end

  @doc """
  Register a callback module for a Script with the provided name.
  """
  def register(callback_module) do
    Logger.info("Registering Script with name `#{callback_module.name()}` and module `#{inspect(callback_module)}`")
    Cache.set(@cache, callback_module.name(), callback_module)
  end

  @doc """
  Check to see if a Script has been registered with the provided name.
  """
  def registered?(callback_module) do
    Logger.info("Checking registration of Script with name `#{callback_module.name()}`")
    Cache.exists?(@cache, callback_module.name())
  end

  @doc """
  Unregisters the callback module for a Script with the provided name.
  """
  def unregister(callback_module) do
    Logger.info("Unregistering Script with name `#{callback_module.name()}`")
    Cache.delete(@cache, callback_module.name())
  end


  #
  # Internal Functions
  #


  defp send_message(method, object_id, name, message) do
    try do
      apply(GenServer, method, [via(@script_registry, {object_id, name}), message])
    catch
      :exit, {:noproc, _} -> {:error, :script_not_running}
      :exit, {:normal, _} -> :ok
      :exit, {:shutdown, _} -> :ok
    end
  end

  defp script_query(object_id, name) do
    from script in Script,
      where: script.name == ^name,
      where: script.object_id == ^object_id
  end
end