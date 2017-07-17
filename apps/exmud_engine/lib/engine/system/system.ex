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
      def run(state), do: {:ok, state, :never}

      @doc false
      def start(_args, state), do: {:ok, state, :never}

      @doc false
      def stop(_args, state), do: {:ok, state}

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

  @default_system_options engine_cfg(:default_system_options)
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
    case send_message(:cast, key, message) do
      :ok -> {:ok, true}
      error -> error
    end
  end

  @doc """
  Get the state of a system.
  """
  def get_state(key) do
    case Registry.lookup(@system_registry, key) do
      [] -> do_get_state(key)
      [{system, _metadata}] ->
        try do
          {:ok, GenServer.call(system, :state)}
        catch
          :exit, {:noproc, _} -> do_get_state(key)
        end
    end
  end

  @doc """
  Purge all the data from a system if it is not running.
  """
  def purge(key) do
    case running(key) do
      {:ok, true} ->
        {:error, :system_running}
      {:ok, false} ->
        system_query(key)
        |> Repo.one()
        |> case do
          nil -> {:error, :no_such_system}
          system ->
            {:ok, _} = Repo.delete(system)
            {:ok, deserialize(system.state)}
        end
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
  def start(key, args \\ %{}) do
    if running(key) == {:ok, true} do
      {:error, :already_started}
    else
      case get_registered_callback(key) do
        {:ok, {callback_module, options}} ->
          case Supervisor.start_child(Exmud.Engine.SystemRunnerSupervisor, [key, callback_module, args, options]) do
            {:ok, _} -> {:ok, true}
            error -> error
          end
        error ->
          error
      end
    end
  end

  @doc """
  Stops a system if it is started.
  """
  def stop(key, args \\ %{}) do
    case Registry.lookup(@system_registry, key) do
      [] ->  {:error, :system_not_running}
      [{system, _metadata}] -> GenServer.call(system, {:stop, args})
    end
  end

  def register(key, callback_module, options \\ @default_system_options) do
    Logger.debug("Registering system with key `#{key}` and module `#{inspect(callback_module)}`")
    Cache.set(@system_cache_category, key, {callback_module, Keyword.merge(options, @default_system_options)})
  end

  @doc """
  Check to see if there is a callback module registered with a given key.
  """
  def registered(key) do
    Cache.exists?(@system_cache_category, key)
  end

  def get_registered_callback(key) do
    Logger.debug("Finding registered system for key `#{key}`")
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


  defp do_get_state(key) do
    system_query(key)
    |> Repo.one()
    |> case do
      nil -> {:error, :no_such_system}
      system -> {:ok, deserialize(system.state)}
    end
  end


  defp send_message(method, key, message) do
    case Registry.lookup(@system_registry, key) do
      [] -> {:error, :system_not_running}
      [{system, _metadata}] ->
        apply(GenServer, method, [system, {:message, message}])
    end
  end

  defp system_query(key) do
    from system in System,
      where: system.key == ^key
  end
end