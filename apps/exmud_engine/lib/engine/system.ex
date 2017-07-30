defmodule Exmud.Engine.System do
  @moduledoc """
  A behaviour module for implementing a system within the Exmud engine.

  Systems form the backbone of the engine. They drive time and event based actions, covering everything from weather
  effects to triggering actions. Transitioning between a set schedule, dynamic schedule, and events is seamless and can
  be controlled entirely at runtime simply by modifying the returned system state.

  ## Callbacks
  There are five callbacks required to be implemented in a system. By adding `use Exmud.System` to your module, Exmud
  will automatically define all five callbacks for you, leaving it up to you to implement the ones you want to
  customize.
  """


  #
  # Behavior definition and default callback setup
  #


  @doc """
  Invoked when a message has been sent to the system.

  Must return a tuple in the form of `{reply, state}`. If the message was sent
  as a cast the value of `reply` is ignored.
  """
  @callback handle_message(message, state) :: {reply, state}

  @doc """
  Invoked the first, and only the first, time a system is started.

  If invoked, this callback will come before `start/2` and the state returned
  will be passed to the `start/2` callback.
  """
  @callback initialize(args) :: state

  @doc """
  Invoked when the main loop of the system is to be run again.

  Must return a new state.
  """
  @callback run(state) :: state | {next_iteration, state}

  @doc """
  Invoked when the system is being started.

  Must return a new state.
  """
  @callback start(args, state) :: state | {next_iteration, state}

  @doc """
  Invoked when the system is being stopped.

  Must return a new state.
  """
  @callback stop(args, state) :: state

  @typedoc "Arguments passed through to a callback module."
  @type args :: term

  @typedoc "What triggered the run callback."
  @type event :: :timer | term

  @typedoc "A message passed through to a callback module."
  @type message :: term

  @typedoc "How many milliseconds should pass until the run callback is called again."
  @type next_iteration :: integer

  @typedoc "A reply passed through to the caller."
  @type reply :: term

  @typedoc "State used by the callback module."
  @type state :: term

  @doc false
  defmacro __using__(_) do
    quote location: :keep do
      @behaviour Exmud.Engine.System

      @doc false
      def handle_message(message, state), do: {:ok, message, state}

      @doc false
      def initialize(args, initial_state \\ %{}), do: {:ok, initial_state}

      @doc false
      def run(state), do: {:ok, 42, state}

      @doc false
      def start(_args, state), do: {:ok, state, state}

      @doc false
      def stop(_args, state), do: {:ok, state, state}

      defoverridable [handle_message: 2,
                      initialize: 2,
                      run: 1,
                      start: 2,
                      stop: 2]
    end
  end


  #
  # API
  #


  alias Exmud.Engine.Cache
  alias Exmud.Engine.Repo
  alias Exmud.Engine.Schema.System
  import Ecto.Query
  import Exmud.Common.Utils
  import Exmud.Engine.Utils
  require Logger

  @system_registry system_registry()
  @system_cache_category :system_cache

  @doc """
  Call a running system with a message.
  """
  def call(key, message) do
    send_message(:call, key, message)
  end

  @doc """
  Cast a message to a running system.
  """
  def cast(key, message) do
    send_message(:cast, key, message)

    {:ok, true}
  end

  @doc """
  Get the state of a system.
  """
  def get_state(key) do
    try do
      GenServer.call(via(@system_registry, key), :state, :infinity)
    catch
      :exit, {:noproc, _} ->
        system_query(key)
        |> Repo.one()
        |> case do
          nil -> {:error, :no_such_system}
          system -> {:ok, deserialize(system.state)}
        end
    end
  end

  @doc """
  Purge system data from the database.
  """
  def purge(key) do
    system_query(key)
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
  as soon as it can and the result returned.
  """
  def run(key) do
    try do
      GenServer.call(via(@system_registry, key), :manual_run, :infinity)
    catch
      :exit, {:noproc, _} -> {:error, :system_not_running}
    end
  end

  @doc """
  Check to see if a system is running.
  """
  def running(key) do
    result = Registry.lookup(@system_registry, key)
    {:ok, result != []}
  end

  @doc """
  Starts a system if it is not already started.
  """
  def start(key, args \\ nil) do
    with  {:ok, callback_module} <- lookup(key),
          {:ok, _} <- Supervisor.start_child(Exmud.Engine.SystemRunnerSupervisor, [key, callback_module, args]),

      do: {:ok, true}
  end

  @doc """
  Stops a system if it is started.
  """
  def stop(key, args \\ %{}) do
    try do
      GenServer.call(via(@system_registry, key), {:stop, args}, :infinity)
    catch
      :exit, {:noproc, _} -> {:error, :system_not_running}
    end
  end

  def register(key, callback_module) do
    Logger.debug("Registering system with key `#{key}` and module `#{inspect(callback_module)}`")
    Cache.set(@system_cache_category, key, callback_module)
  end

  @doc """
  Check to see if there is a callback module registered with a given key.
  """
  def registered?(key) do
    Cache.exists?(@system_cache_category, key)
  end

  def lookup(key) do
    Logger.debug("Finding module for system registered with key `#{key}`")
    case Cache.get(@system_cache_category, key) do
      {:missing, _} ->
        Logger.warn("Attempt to find system callback module for key `#{key}` failed")
        {:error, :no_such_system}
      {:ok, callback} ->
        {:ok, callback}
    end
  end

  @doc false
  def unregister(key) do
    Cache.delete(@system_cache_category, key)
  end


  #
  # Internal Functions
  #


  defp send_message(method, key, message) do
    try do
      apply(GenServer, method, [via(@system_registry, key), {:message, message}])
    catch
      :exit, {:noproc, _} -> {:error, :system_not_running}
    end
  end

  defp system_query(key) do
    from system in System,
      where: system.key == ^key
  end
end