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
      alias Exmud.Engine.Script.Result

      @doc false
      def handle_message(_object_id, message, state), do: {:ok, message, state}

      @doc false
      def initialize(object_id, _args), do: {:ok, object_id}

      @doc false
      def run(_object_id, state), do: {:ok, state}

      @doc false
      def start(_object_id, _args, state), do: {:ok, state, 0}

      @doc false
      def stop(_object_id, _reason, state), do: {:ok, state}

      defoverridable handle_message: 3,
                     initialize: 2,
                     run: 2,
                     start: 3,
                     stop: 3
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
  per Script callback_module/Dedupe Key combination.

  If called, it will immediately precede `start/2` and the returned state will be passed to the `start/2` callback. If a
  Script has been previously initialized, the persisted state is loaded from the database and used in the `start/2`
  callback instead.
  """
  @callback initialize(object_id, args) :: {:ok, state} | {:error, reason}

  @doc """
  Called in response to an interval period expiring, or an explicit call to run the Script again. Unlike Systems, a
  Script is always expected to be running.
  """
  @callback run(object_id, state) ::
              {:ok, state}
              | {:ok, state, next_iteration}
              | {:stop, reason, state}
              | {:error, error, state}
              | {:error, error, state, next_iteration}

  @doc """
  Called when the Script is being started.

  If this is the first time the Script has been started it will immediately follow a call to 'initialize/2' and will be
  called with the state returned from the previous call, otherwise the state will be loaded from the database and used
  instead. Must return a new state.
  """
  @callback start(object_id, args, state) :: {:ok, state, next_iteration} | {:error, error, state}

  @doc """
  Called when the Script is being stopped.

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

  @typedoc "The reason the Script is stopping."
  @type reason :: term

  @typedoc "State used by the callback module."
  @type state :: term

  @typedoc "Id of the Object the Script is attached to."
  @type object_id :: integer

  @typedoc "The callback_module that is the implementation of the Script logic."
  @type callback_module :: atom

  alias Exmud.Engine.CallbackSupervisor
  alias Exmud.Engine.ObjectUtil
  alias Exmud.Engine.Repo
  alias Exmud.Engine.Schema.Script
  alias Exmud.Engine.Worker.ScriptWorker
  require Logger
  import Ecto.Query
  import Exmud.Common.Utils
  import Exmud.Engine.Constants

  @script_registry script_registry()

  #
  # Manipulation of a single Script on an Object
  #

  @doc """
  Attach a Script to an Object.
  """
  @spec attach(object_id, callback_module, args | nil) ::
          :ok | {:error, :no_such_object | :already_attached}
  def attach(object_id, callback_module, config \\ nil) do
    initialization_result = apply(callback_module, :initialize, [object_id, config])

    case initialization_result do
      {:ok, new_state} ->
        Logger.info(
          "Script `#{callback_module}` successfully initialized for Object `#{object_id}`."
        )

        script =
          %{
            object_id: object_id,
            callback_module: pack_term(callback_module),
            state: pack_term(new_state)
          }
          |> Exmud.Engine.Schema.Script.new()

        ObjectUtil.attach(script)

        :ok

      {_, error} = error_result ->
        Logger.error(
          "Encountered error `#{error}` while initializing Script `#{callback_module}` for Object `#{
            object_id
          }`."
        )

        error_result
    end
  end

  @doc """
  Call a running Script with a message.
  """
  @spec call(object_id, callback_module, message) :: {:ok, reply}
  def call(object_id, callback_module, message) do
    send_message(:call, object_id, callback_module, {:message, message})
  end

  @doc """
  Call a running Script with a message, or use that message as the argument for starting that Script on that Object.
  """
  @spec call_or_start(object_id, callback_module, message) ::
          :ok | {:ok, term} | {:error, :no_such_script}
  def call_or_start(object_id, callback_module, message) do
    case send_message(:call, object_id, callback_module, {:message, message}) do
      {:error, _} ->
        start(object_id, callback_module, message)

      ok_result ->
        ok_result
    end
  end

  @doc """
  Cast a message to a running Script.
  """
  @spec cast(object_id, callback_module, message) :: :ok
  def cast(object_id, callback_module, message) do
    send_message(:cast, object_id, callback_module, {:message, message})
  end

  @doc """
  Detach a Script from an Object.

  This method first stops the Script if it is running before moving on to removing the Script from the database. It is
  also destructive, with the state of the Script being destroyed at the time of removal.
  """
  @spec detach(object_id, callback_module) :: :ok | {:error, :no_such_script}
  def detach(object_id, callback_module) do
    stop(object_id, callback_module)
    purge(object_id, callback_module)
  end

  @doc """
  Get the state of a Script.

  First the running Script will be queried for the state, and then the database. Only if both fail to return a result is
  an error returned.
  """
  @spec get_state(object_id, callback_module) :: {:ok, term} | {:error, :no_such_script}
  def get_state(object_id, callback_module) do
    try do
      GenServer.call(via(@script_registry, {object_id, callback_module}), :state, :infinity)
    catch
      :exit, {:noproc, _} ->
        script_query(object_id, callback_module)
        |> Repo.one()
        |> case do
          nil ->
            {:error, :no_such_script}

          script ->
            {:ok, unpack_term(script.state)}
        end
    end
  end

  @doc """
  Check to see if a Script is attached to an Object.
  """
  @spec is_attached?(object_id, callback_module) :: boolean
  def is_attached?(object_id, callback_module) do
    query = from(script in script_query(object_id, callback_module), select: count("*"))

    Repo.one(query) == 1
  end

  @doc """
  Purge Script data from the database.

  This method does not check for a running Script, or in any way ensure that the data can't or won't be rewritten.
  It is a dumb delete.
  """
  @spec purge(object_id, callback_module) :: :ok | {:error, :no_such_script}
  def purge(object_id, callback_module) do
    script_query(object_id, callback_module)
    |> Repo.delete_all()
    |> case do
      {1, _} -> :ok
      {0, _} -> {:error, :no_such_script}
    end
  end

  @doc """
  Trigger a Script to run immediately. If a Script is running while this call is made the Script will run again as soon
  as it can.

  This method ensures that the Script is active and that it will begin the process of running its main loop immediately,
  but offers no other guarantees.
  """
  @spec run(object_id, callback_module) :: :ok | {:error, :no_such_script}
  def run(object_id, callback_module) do
    send_message(:call, object_id, callback_module, :run)
  end

  @doc """
  Check to see if a Script is running on an Object.

  This method is not for checking if the Script is running its main loop at that moment, but to check if it is still
  active or if it is currently stopped. If there is no Script running matching the provided parameters, it does not
  check the database to validate that such a Script actively exists. To check if an Object has a Script attached to it,
  see the 'has?/2' method.
  """
  @spec running?(object_id, callback_module) :: boolean
  def running?(object_id, callback_module) do
    send_message(:call, object_id, callback_module, :running) == true
  end

  @doc """
  Start a specific Script on an Object. The Script must already be attached.
  """
  @spec start(object_id, callback_module, args | nil) :: :ok | {:error, :no_such_script}
  def start(object_id, callback_module, start_args \\ nil) do
    gen_server_args = [
      object_id,
      callback_module,
      start_args
    ]

    with {:ok, _} <-
           DynamicSupervisor.start_child(CallbackSupervisor, {ScriptWorker, gen_server_args}) do
      :ok
    end
  end

  @doc """
  Start all Scripts on an Object. Will only start attached Scripts.
  """
  @spec start_all(object_id, args) ::
          {:ok, %{required(module()) => :ok | {:error, :already_started}}}
          | {:error, :no_scripts_attached}
  def start_all(object_id, start_args \\ nil) do
    from(
      script in Script,
      where: script.object_id == ^object_id
    )
    |> Repo.all()
    |> case do
      [] ->
        {:error, :no_scripts_attached}

      scripts ->
        Enum.reduce(scripts, %{}, fn script, map ->
          callback_module = unpack_term(script.callback_module)
          Map.put(map, callback_module, start(object_id, callback_module, start_args))
        end)
    end
  end

  @doc """
  Stops a Script if it is started.
  """
  @spec stop(object_id, callback_module) :: :ok | {:error, :no_such_script}
  def stop(object_id, callback_module) do
    case Registry.lookup(@script_registry, {object_id, callback_module}) do
      [{pid, _}] ->
        ref = Process.monitor(pid)
        GenServer.stop(pid, :normal)

        receive do
          {:DOWN, ^ref, :process, ^pid, :normal} ->
            :ok
        end

      _ ->
        {:error, :no_such_script}
    end
  end

  @doc """
  Update the state of a Script in the database.

  Primarily used by the Engine to persist the state of a running Script whenever it changes.
  """
  @spec update(object_id, callback_module, state) :: :ok | {:error, :no_such_script}
  def update(object_id, callback_module, state) do
    query = script_query(object_id, callback_module)

    case Repo.update_all(query, set: [state: pack_term(state)]) do
      {1, _} -> :ok
      {0, _} -> {:error, :no_such_script}
    end
  end

  #
  # Internal Functions
  #

  @spec send_message(method :: atom, object_id, callback_module, message) ::
          :ok | {:ok, term} | {:error, :script_not_running}
  defp send_message(method, object_id, callback_module, message) do
    try do
      apply(GenServer, method, [via(@script_registry, {object_id, callback_module}), message])
    catch
      :exit, _ -> {:error, :no_such_script}
    end
  end

  @spec script_query(object_id, callback_module) :: term
  defp script_query(object_id, callback_module) do
    from(
      script in Script,
      where: script.callback_module == ^pack_term(callback_module),
      where: script.object_id == ^object_id
    )
  end
end
