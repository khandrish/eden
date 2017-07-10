defmodule Exmud.Session.SessionWorker do
  @moduledoc """
  A module for the manipulation of and communication with `Exmud.Player`
  sessions.

  Each `Exmud.Player` object can only have a single session active at a time,
  through which all communication to and from the player flows. In this way
  the player session acts as both a synchronization mechanism as well as a
  bottleneck which can provide backpressure when required to keep the system
  healthy.
  """

  defmodule State do
    defstruct active_input: nil, # Input being processed.
              active_task: nil, # Task processing input.
              event_manager: nil, # Event manager for output stream.
              input_queue: EQueue.new(), # Holds all input waiting to be processed.
              key: nil, # The unique key identifying the player that the session represents.
              message_queue: EQueue.new(), # Holds all output waiting to be sent, only populated if no listeners.
              object: nil, # The id of the object that represents the player in the system.
              start_time: nil # The time the session was started.
  end

  alias Ecto.Multi
  # alias Exmud.Engine.CommandProcessor
  # alias Exmud.Engine.CommandSet
  # alias Exmud.Engine.Object
  # alias Exmud.Engine.Player
  alias Exmud.Session.SessionSup
  alias Exmud.Session.SessionOutputHandler
  # alias Exmud.Repo
  import Exmud.Common.Utils
  # import IO, only: [inspect: 2]
  require Logger
  use GenServer

  @player_category "player"
  @registry :player_session_registry


  #
  # Type definitions
  #


  @typedoc "The string, such as `move north`, that is to be processed."
  @type command_string :: String.t

  @typedoc "The unique string that identifies the player."
  @type key :: String.t


  #
  # API
  #


  @doc """
  Check to see if a player has a session currently active.

  ## Examples

      Exmud.PlayerSession.active(:marie_curie)
  """
  @spec active(any) :: {:ok, boolean}
  def active(key) do
    {:ok, Registry.lookup(@registry, key) != []}
  end

  @doc """
  Send input to the game engine on behalf of the player via its active session.

  A successful return from this function guarantees that the player session has
  received the input. It does not garuntee that the input will be processed.

  ## Examples

      Exmud.PlayerSession.process_command_string(:louis_pasteur, "Pasteurization")
  """
  @spec process_command_string(key, command_string) :: {:ok, :success} | {:error, :no_session_active}
  def process_command_string(key, command_string) do
    forward(key, {:process_command_string, command_string})
  end

  @doc """
  Send message to the player via its active session.

  A successful return from this function does not guarantee that the player has
  or will ever actually receive the output, only that the active player session
  process has accepted the output and will attempt to deliver the output as
  soon as possible.

  ## Examples

      Exmud.PlayerSession.send_message(:james_watson, "The Double Helix")
  """
  @spec send_message(key :: any, message :: any) :: {:ok, :success} | {:error, :no_session_active}
  def send_message(key, message) do
    forward(key, {:send_message, message})
  end

  # @doc """
  # Start a new player session.

  # An `Exmud.Player` must have been registered with the `key` prior to starting
  # a session for said player.

  # ## Examples

  #     Exmud.PlayerSession.start(:francis_crick)
  # """
  # @spec start(key :: any) :: {:ok, :success} | {:error, :no_such_player}
  # def start(key) do
  #   case Player.which(key) do
  #     {:ok, oid} ->
  #       {:ok, _pid} = Supervisor.start_child(SessionSup, [key, oid])
  #       {:ok, :success}
  #     error ->
  #       error
  #   end
  # end


  @doc """
  Stop an active player session.

  ## Examples

      Exmud.PlayerSession.stop(:robert_boyle)
  """
  @spec stop(any) :: {:ok, :success} | {:error, :no_session_active}
  def stop(key) do
    forward(key, :stop)
  end


  @doc """
  Stream all output sent through an active player session through the provided
  handler function.

  The handler function should be as simple as possible, ideally doing no more
  than acting as a proxy that determines where and in what format the message
  is sent.

  ## Examples

      Exmud.PlayerSession.stream_output(:ada_lovelace, fn message -> send(destination, {:incoming, message}) end)
  """
  @spec stream_output(any, fun) :: {:ok, :success} | {:error, :no_session_active}
  def stream_output(key, handler_fun) do
    forward(key, {:stream_output, handler_fun})
  end


  #
  # Worker callback
  #


  @doc false
  @spec start_link(any, any) :: {:ok, pid}
  def start_link(key, oid), do: GenServer.start_link(__MODULE__, {key, oid}, name: via_tuple(@registry, key))


  #
  # GenServer Callbacks
  #


  @doc false
  @spec init({key :: any, oid :: any}) :: {:ok, %State{}}
  def init({key, oid}) do
    {:ok, pid} = GenEvent.start_link([])
    {:ok, %State{event_manager: pid, key: key, object: oid, start_time: Calendar.DateTime.now_utc()}}
  end

  @doc false
  @spec handle_call(:stop, any, %State{}) :: {:stop, :normal, :ok, %State{}}
  def handle_call(:stop, _from, state) do
    {:stop, :normal, :ok, state}
  end

  @doc false
  @spec handle_call({:process_command_string, command_string :: String.t}, any, %State{}) :: {:reply, :ok, %State{}}
  def handle_call({:process_command_string, command_string}, _from, state) do
    if taskActive?(state) do
      {:reply, :ok, %{state | input_queue: EQueue.push(state.input_queue, command_string)}}
    else
      task =
        Task.async(fn ->
            # CommandProcessor.process(command_string, state.object)

            # If no command sets match, trigger the no match behaviour/error via callback
            # = merge_command_sets(command_set_templates)
            #
            #
            #
            #
            #
            # match against command set
            # multi error? no match error?
            # execute command
            :ok
        end)

      # state = case Task.yield(task, 10) do
      #   nil ->
      #     input_queue = EQueue.from_list([task]) |> EQueue.join(state.input_queue)
      #     %{state | active_task: task, input_queue: input_queue}
      #   {:ok, result} ->
      #     %{state | active_task: task, input_queue: Equeue.pop()}
      # end
      {:reply, :ok, %{state | active_task: task}}
    end
  end

  @doc false
  @spec handle_call({:send_message, message :: String.t}, any, %State{}) :: {:reply, :ok, %State{}}
  def handle_call({:send_message, message}, _from, state) do
    if GenEvent.which_handlers(state.event_manager) != [] do
      :ok = GenEvent.notify(state.event_manager, message)
      {:reply, :ok, state}
    else
      {:reply, :ok, %{state | message_queue: EQueue.push(state.message_queue, message)}}
    end
  end

  @doc false
  @lint {Credo.Check.Refactor.PipeChainStart, false}
  @spec handle_call({:stream_output, handler :: fun}, any, %State{}) :: {:reply, :ok, %State{}}
  def handle_call({:stream_output, handler_fun}, _from, state) do
    :ok = GenEvent.add_handler(state.event_manager, SessionOutputHandler, handler_fun)

    if EQueue.length(state.message_queue) > 0 do
      EQueue.to_list(state.message_queue)
      |> Enum.each(&(:ok = GenEvent.notify(state.event_manager, &1)))
    end

    {:reply, :ok, %{state | message_queue: EQueue.new()}}
  end


  #
  # Private Functions
  #


  @spec forward(key :: any, message :: String.t) :: {:ok, :success} | {:error, :no_session_active}
  defp forward(key, message) do
    case active(key) do
      {:ok, false} -> {:error, :no_session_active}
      {:ok, true} ->
        via = via_tuple(@registry, key)
        :ok = GenServer.call(via, message)
        {:ok, :success}
    end
  end

  @spec taskActive?(%State{}) :: true | false
  defp taskActive?(%State{active_task: nil}), do: false
  defp taskActive?(_), do: true
end