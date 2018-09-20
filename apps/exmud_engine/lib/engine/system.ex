defmodule Exmud.Engine.System do
  @moduledoc """
  Systems form the backbone of the Engine, driving time and message based actions within the game world.

  Examples include weather effects, triggering invasions, regular spawning of critters, the day/night cycle, and so on.
  Unlike Scripts, which can be added as many times to as many different Objects as you want, only one of each registered
  System may run at a time.

  Systems can transition between a set schedule, dynamic schedule, and purely message based seamlessly at runtime simply
  by modifying the value returned from the `run/1` callback. Note that while it is possible to run only in response to
  being explicitly called, short of not implementing the `handle_message/2` callback it is not possible for the Engine
  to run in a schedule only mode. Only you can prevent messages by not calling the System directly in your code.

  Under the hood, Systems are simply Scripts which are treated just a little bit differently. That said, you must not
  use the same callback module for a System as you do for a Script. It will cause odd and unexpected things to happen.
  """

  @doc false
  defmacro __using__(_) do
    quote location: :keep do
      use Exmud.Engine.Script
    end
  end

  #
  # Behavior definition and default callback setup
  #

  @doc """
  Handle a message which has been explicitly sent to the System.
  """
  @callback handle_message(object_id, message, state) :: {:ok, reply, state} | {:error, reason}

  @doc """
  Called the first, and only the first, time a System is started.

  If called, it will immediately precede `start/2` and the returned state will be passed to the `start/2` callback.
  If a System has been previously initialized, the persisted state is loaded from the database and used in the `start/2`
  callback instead.
  """
  @callback initialize(object_id, args) :: {:ok, state} | {:error, reason}

  @doc """
  The name of the System.
  """
  @callback name :: String.t()

  @doc """
  Called in response to an interval period expiring, or an explicit call to run the System again.
  """
  @callback run(object_id, state) ::
              {:ok, state}
              | {:ok, state, next_iteration}
              | {:stop, reason, state}
              | {:error, error, state}
              | {:error, error, state, next_iteration}

  @doc """
  Called when the System is being started.

  If this is the first time the System has been started it will immediately follow a call to 'initialize/2' and will be
  called with the state returned from the previous call, otherwise the state will be loaded from the database and used
  instead. Must return a new state and an optional timeout, in milliseconds, until the next iteration.
  """
  @callback start(object_id, args, state) ::
              {:ok, state} | {:ok, state, next_iteration} | {:error, error}

  @doc """
  Called when the System is being stopped.

  Must return a new state which will be persisted.
  """
  @callback stop(object_id, args, state) :: {:ok, state} | {:error, error}

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

  @typedoc "Id of the Object representing the System within the Engine."
  @type object_id :: integer

  @typedoc "The name of the System within the Engine."
  @type name :: String.t()

  @typedoc "The callback_module that is the implementation of the Script logic."
  @type callback_module :: atom

  #
  # API
  #

  alias Exmud.Engine.Cache
  alias Exmud.Engine.Object
  alias Exmud.Engine.Repo
  alias Exmud.Engine.Schema.Script
  alias Exmud.Engine.ScriptRunner
  import Ecto.Query
  import Exmud.Common.Utils
  import Exmud.Engine.Utils
  import Exmud.Engine.Constants
  require Logger

  @system_registry system_registry()

  @doc """
  Call a running system with a message.
  """
  @spec call(name, message) :: {:ok, reply}
  def call(name, message) do
    send_message(:call, name, {:message, message})
  end

  @doc """
  Cast a message to a running system.
  """
  @spec cast(name, message) :: :ok
  def cast(name, message) do
    send_message(:cast, name, {:message, message})

    :ok
  end

  @doc """
  Get the state of a system.
  """
  @spec get_state(name) :: {:ok, term} | {:error, :no_such_system}
  def get_state(name) do
    try do
      GenServer.call(via(@system_registry, name), :state, :infinity)
    catch
      :exit, {:noproc, _} ->
        system_query(name)
        |> Repo.one()
        |> case do
          nil ->
            {:error, :no_such_system}

          system ->
            {:ok, deserialize(system.state)}
        end
    end
  end

  @doc """
  Purge system data from the database. Does not check if system is running
  """
  @spec purge(name) :: :ok | {:error, :no_such_system}
  def purge(name) do
    system_query(name)
    |> Repo.one()
    |> case do
      nil ->
        {:error, :no_such_system}

      system ->
        {:ok, _} = Repo.delete(system)
        :ok
    end
  end

  @doc """
  Trigger a system to run immediately. If a system is running while this call is made the system will run again
  as soon as it can and the result of that run is returned.

  This method ensures that the System is active and that it will begin the process of running its main loop immediately,
  but offers no other guarantees.
  """
  @spec run(name) :: :ok | {:error, :no_such_system}
  def run(name) do
    send_message(:call, name, :run)
  end

  @doc """
  Check to see if a system is running.
  """
  @spec running?(name) :: boolean
  def running?(name) do
    send_message(:call, name, :running) == true
  end

  @doc """
  Start a system.
  """
  @spec start(name, args :: term) :: :ok | {:error, :no_such_system}
  def start(name, callback_module_arguments \\ nil) do
    object_id =
      case Repo.one(system_query(name)) do
        nil ->
          Object.new!()

        system ->
          system.object_id
      end

    with {:ok, callback_module} <- lookup(name) do
      process_registration_name = via(@system_registry, name)

      gen_server_args = [
        object_id,
        name,
        callback_module,
        callback_module_arguments,
        process_registration_name
      ]

      with {:ok, _} <-
             DynamicSupervisor.start_child(
               Exmud.Engine.CallbackSupervisor,
               {ScriptRunner, gen_server_args}
             ) do
        :ok
      end
    end
  end

  @doc """
  Stops a system if it is started.
  """
  @spec stop(name) :: :ok | {:error, :no_such_script}
  def stop(name) do
    case Registry.lookup(@system_registry, name) do
      [{pid, _}] ->
        ref = Process.monitor(pid)
        GenServer.stop(pid, :normal)

        receive do
          {:DOWN, ^ref, :process, ^pid, :normal} ->
            :ok
        end

      _ ->
        {:error, :no_such_system}
    end
  end

  @doc """
  Update the state of a System in the database.

  Primarily used by the Engine to persist the state of a running System whenever it changes.
  """
  @spec update(name, state) :: :ok | {:error, :no_such_system}
  def update(system_name, state) do
    query = system_query(system_name)

    case Repo.update_all(query, set: [state: pack_term(state)]) do
      {1, _} -> :ok
      _ -> {:error, :no_such_system}
    end
  end

  #
  # Manipulation of Systems in the Engine.
  #

  @cache :system_cache

  @doc """
  List all Systems which have been registered with the engine since the last start.
  """
  @spec list_registered :: :ok | [callback_module]
  def list_registered() do
    Logger.info("Listing all registered Systems")
    Cache.list(@cache)
  end

  @doc """
  Lookup the callback module for the System with the provided name.
  """
  @spec lookup(name) :: {:ok, callback_module} | {:error, :no_such_system}
  def lookup(name) do
    case Cache.get(@cache, name) do
      {:error, _} ->
        Logger.error("Lookup failed for System registered with name `#{name}`")
        {:error, :no_such_system}

      result ->
        Logger.info("Lookup succeeded for System registered with name `#{name}`")
        result
    end
  end

  @doc """
  Register a callback module for a System with the provided name.
  """
  @spec register(callback_module) :: :ok
  def register(callback_module) do
    Logger.info(
      "Registering System with name `#{callback_module.name}` and module `#{
        inspect(callback_module)
      }`"
    )

    Cache.set(@cache, callback_module.name, callback_module)
  end

  @doc """
  Check to see if a System has been registered with the provided name.
  """
  @spec registered?(callback_module) :: boolean
  def registered?(callback_module) do
    Logger.info("Checking registration of System with name `#{callback_module.name()}`")
    Cache.exists?(@cache, callback_module.name())
  end

  @doc """
  Unregisters the callback module for a Script with the provided name.
  """
  @spec unregister(callback_module) :: :ok
  def unregister(callback_module) do
    Logger.info("Unregistering System with name `#{callback_module.name()}`")
    Cache.delete(@cache, callback_module.name())
  end

  #
  # Internal Functions
  #

  @spec send_message(method :: atom, name, message) ::
          :ok | {:ok, term} | {:error, :system_not_running}
  defp send_message(method, name, message) do
    try do
      apply(GenServer, method, [via(@system_registry, name), message])
    catch
      :exit, _ -> {:error, :no_such_system}
    end
  end

  defp system_query(name) do
    from(script in Script, where: script.name == ^name)
  end
end
