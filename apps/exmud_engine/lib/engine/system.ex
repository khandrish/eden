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
  """

  @doc false
  defmacro __using__(_) do
    quote location: :keep do

      @behaviour Exmud.Engine.System

      @doc false
      def handle_message(message, state), do: {:ok, message, state}

      @doc false
      def initialize(_args), do: {:ok, nil}

      @doc false
      def name, do: Atom.to_string(__MODULE__)

      @doc false
      def run(state), do: {:ok, state}

      @doc false
      def start(_args, state), do: {:ok, state}

      @doc false
      def stop(_args, state), do: {:ok, state}

      defoverridable [handle_message: 2,
                      initialize: 1,
                      name: 0,
                      run: 1,
                      start: 2,
                      stop: 2]
    end
  end


  #
  # Behavior definition and default callback setup
  #


  @doc """
  Handle a message which has been explicitly sent to the System.
  """
  @callback handle_message(message, state) :: {:ok, reply, state} | {:error, reason}

  @doc """
  Called the first, and only the first, time a System is started.

  If called, it will immediately precede `start/2` and the returned state will be passed to the `start/2` callback.
  If a System has been previously initialized, the persisted state is loaded from the database and used in the `start/2`
  callback instead.
  """
  @callback initialize(args) :: {:ok, state} | {:error, reason}

  @doc """
  The name of the System.
  """
  @callback name :: String.t

  @doc """
  Called in response to an interval period expiring, or an explicit call to run the System again.
  """
  @callback run(state) :: {:ok, state} |
                          {:ok, state, next_iteration} |
                          {:stop, reason, state} |
                          {:error, error, state} |
                          {:error, error, state, next_iteration}

  @doc """
  Called when the System is being started.

  If this is the first time the System has been started it will immediately follow a call to 'initialize/2' and will be
  called with the state returned from the previous call, otherwise the state will be loaded from the database and used
  instead. Must return a new state and an optional timeout, in milliseconds, until the next iteration.
  """
  @callback start(args, state) :: {:ok, state} | {:ok, state, next_iteration} | {:error, error}

  @doc """
  Called when the System is being stopped.

  Must return a new state which will be persisted.
  """
  @callback stop(args, state) :: {:ok, state} | {:error, error}

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


  #
  # API
  #


  alias Exmud.Engine.Cache
  alias Exmud.Engine.Repo
  alias Exmud.Engine.Schema.System
  import Ecto.Query
  import Exmud.Common.Utils
  require Logger

  @system_registry :exmud_engine_system_registry

  @doc """
  Call a running system with a message.
  """
  def call(name, message) do
    send_message(:call, name, message)
  end

  @doc """
  Cast a message to a running system.
  """
  def cast(name, message) do
    send_message(:cast, name, message)

    {:ok, true}
  end

  @doc """
  Get the state of a system.
  """
  def get_state(name) do
    try do
      GenServer.call(via(@system_registry, name), :state, :infinity)
    catch
      :exit, {:noproc, _} ->
        system_query(name)
        |> Repo.one()
        |> case do
          nil -> {:error, :no_such_system}
          system ->
            {:ok, deserialize(system.state)}
        end
    end
  end

  @doc """
  Purge system data from the database. Does not check if system is running
  """
  def purge(name) do
    system_query(name)
    |> Repo.one()
    |> case do
      nil -> {:error, :no_such_system}
      system ->
        {:ok, _} = Repo.delete(system)
        {:ok, deserialize(system.state)}
    end
  end

  @doc """
  Trigger a system to run immediately. If a system is running while this call is made the system will run again
  as soon as it can and the result of that run is returned.
  """
  def run(name) do
    try do
      GenServer.call(via(@system_registry, name), :run, :infinity)
    catch
      :exit, {:noproc, _} -> {:error, :system_not_running}
    end
  end

  @doc """
  Check to see if a system is running.
  """
  def running?(name) do
    result = Registry.lookup(@system_registry, name)
    {:ok, result != []}
  end

  @doc """
  Start a system.
  """
  def start(name, args \\ nil) do
    with  {:ok, _} <- Supervisor.start_child(Exmud.Engine.SystemRunnerSupervisor, [name, args]),

      do: {:ok, :started}
  end

  @doc """
  Stops a system if it is started.
  """
  def stop(name, args \\ %{}) do
    try do
      GenServer.call(via(@system_registry, name), {:stop, args}, :infinity)
    catch
      :exit, {:noproc, _} -> {:error, :system_not_running}
    end
  end


  #
  # Manipulation of Systems in the Engine.
  #


  @cache :system_cache

  def list_registered() do
    Logger.info("Listing all registered Systems")
    Cache.list(@cache)
  end

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

  def register(callback_module) do
    Logger.info("Registering System with name `#{callback_module.name}` and module `#{inspect(callback_module)}`")
    Cache.set(@cache, callback_module.name, callback_module)
  end

  def registered?(name) do
    Logger.info("Checking registration of System with name `#{name}`")
    Cache.exists?(@cache, name)
  end

  def unregister(name) do
    Logger.info("Unregistering System with name `#{name}`")
    Cache.delete(@cache, name)
  end


  #
  # Internal Functions
  #


  defp send_message(method, name, message) do
    try do
      apply(GenServer, method, [via(@system_registry, name), {:message, message}])
    catch
      :exit, {:noproc, _} -> {:error, :system_not_running}
    end
  end

  defp system_query(name) do
    from system in System,
      where: system.name == ^name
  end
end