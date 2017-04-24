defmodule Exmud.System do
  @moduledoc """
  A behaviour module for implementing a system within the Exmud engine.

  Systems form the backbone of the engine. They drive time and event based
  actions, covering everything from weather effects to triggering AI actions.

  Systems do not have to run on a set schedule and instead can only react to
  events, and vice versa. See documentation for `c:initialize/1` for details.

  ## Callbacks
  There are five callbacks required to be implemented in a system. By adding
  `use Exmud.System` to your module, Elixir will automatically define all
  five callbacks for you, leaving it up to you to implement the ones you want
  to customize.
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
  @callback run(event, state) :: state | {next_iteration, state}

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
      @behaviour Exmud.System

      @doc false
      def handle_message(message, state), do: {message, state}

      @doc false
      def initialize(args), do: Map.new()

      @doc false
      def run(event, state), do: state

      @doc false
      def start(_args, state), do: state

      @doc false
      def stop(_args, state), do: state

      defoverridable [handle_message: 2,
                      initialize: 1,
                      run: 2,
                      start: 2,
                      stop: 2]
    end
  end


  #
  # API
  #


  alias Exmud.Registry
  alias Exmud.Repo
  alias Exmud.Schema.System, as: S
  import Ecto.Query

  @system_category "system"

  @doc """
  Call a running system with a message.
  """
  def call(key, message) do
    case Registry.read_key(key, @system_category) do
      {:error, :no_such_key} -> {:error, :no_such_system}
      {:ok, pid} ->
        GenServer.call(pid, {:message, message})
    end
  end

  @doc """
  Cast a message to a running system.
  """
  def cast(key, message) do
    case Registry.read_key(key, @system_category) do
      {:error, :no_such_key} -> {:error, :no_such_system}
      {:ok, pid} ->
        GenServer.cast(pid, {:message, message})
        :ok
    end
  end

  @doc """
  Purge all the data from a system if it is not running.
  """
  @lint {Credo.Check.Refactor.PipeChainStart, false}
  def purge(key) do
    case running?(key) do
      true ->
        {:error, :system_running}
      false ->
        Repo.one(
          from system in S,
          where: system.key == ^key,
          select: system
        )
        |> case do
          nil -> {:error, :no_such_system}
          system ->
            {:ok, _} = Repo.delete(system)
            {:ok, :erlang.binary_to_term(system.state)}
        end
    end
  end

  @doc """
  Check to see if a system is running.
  """
  def running?(key) do
    {result, _reply} = Registry.read_key(key, @system_category)
    result == :ok
  end

  @doc """
  Starts a system if it is not already started.
  """
  def start(key, callback_module, args \\ %{}) do
    if running?(key) do
      {:error, :already_started}
    else
      {:ok, _} = Supervisor.start_child(Exmud.SystemSup, [key, callback_module, args])
      :ok
    end
  end

  @doc """
  Stops a system if it is started.
  """
  def stop(key, args \\ %{}) do
    case Registry.read_key(key, @system_category) do
      {:ok, pid} ->  GenServer.call(pid, {:stop, args})
      {:error, :no_such_key} -> {:error, :no_such_system}
    end
  end


  #
  # Internal Functions
  #


  def send_message(method, key, message) do
    case Registry.read_key(key, @system_category) do
      {:error, :no_such_key} -> {:error, :no_such_system}
      {:ok, pid} ->
        apply(GenServer, method, [pid, {:message, message}])
    end
  end
end
