defmodule Exmud.Game.System do
  @moduledoc """
  Systems form the backbone of the Game, driving time and message based actions within the game world.

  Examples include weather effects, triggering invasions, regular spawning of critters, the day/night cycle, and so on.
  Unlike Scripts, which can be added as many times to as many different Objects as you want, only one of each registered
  System may run at a time.

  Systems can transition between a set schedule, dynamic schedule, and purely message based seamlessly at runtime simply
  by modifying the value returned from the `run/1` callback. Note that while it is possible to run only in response to
  being explicitly called, short of not implementing the `handle_message/2` callback it is not possible for the Engine
  to enforce a schedule only mode. Only you can prevent messages by not calling the System directly in your code.

  ## Callbacks
  There are five callbacks required to implement a System. By adding `use Exmud.Game.System` to your module, all of
  them will be defined with sane defaults. It will be up to you to customize the logic as required.
  """

  @doc """
  Called when a message has been sent to the System.
  """
  @callback handle_message(message, state) :: {:ok, reply, state} | {:error, error, state}

  @doc """
  Called the first, and only the first, time a System is started.

  If called, it will immediately precede `start/2` and the returned value will be passed to the `start/2` callback. If a
  system has been initialized once, the persisted state is loaded from the database and used in the `start/2` callback
  instead.
  """
  @callback initialize(args) :: {:ok, state} | {:error, reason}

  @doc """
  Called in response to an interval period expiring, or an explicit call to start the System again.
  """
  @callback run(state) :: {:ok, state} |
                          {:ok, state, next_iteration} |
                          {:stop, reason, state} |
                          {:error, error, state}

  @doc """
  Called when the system is being started.

  Must return a new state.
  """
  @callback start(args, state) :: {:ok, state} | {:ok, state, next_iteration} | {:error, error}

  @doc """
  Called when the system is being stopped.

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

  @doc false
  defmacro __using__(_) do
    quote location: :keep do
      @behaviour Exmud.Game.System

      @doc false
      def handle_message(message, state), do: {:ok, message, state}

      @doc false
      def initialize(_args), do: {:ok, nil}

      @doc false
      def run(state), do: {:ok, state}

      @doc false
      def start(_args, state), do: {:ok, state}

      @doc false
      def stop(_args, state), do: {:ok, state}

      defoverridable [handle_message: 2,
                      initialize: 1,
                      run: 1,
                      start: 2,
                      stop: 2]
    end
  end
end