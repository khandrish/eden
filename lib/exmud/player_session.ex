defmodule Exmud.PlayerSession do
  @moduledoc """
  A module for the manipulation of and communication with `Exmud.Player`
  sessions.

  Each `Exmud.Player` object can only have a single session active at a time,
  through which all communication to and from the player flows. In this way
  the player session acts as both a synchronization mechanism as well as a
  bottleneck which can provide backpressure when required to keep the system
  healthy.

  Note: None of the functions in this module are pure. All have side effects.
  """

  defmodule State do
    defstruct event_manager: nil, key: nil, message_queue: EQueue.new(), start_time: nil
  end

  alias Exmud.Player
  alias Exmud.PlayerSessionSup
  alias Exmud.PlayerSessionOutputHandler
  alias Exmud.PlayerSessionStreamSup
  import Exmud.Utils
  use GenServer

  @player_category "player"
  @registry :player_session_registry


  #
  # API
  #


  @doc """
  Check to see if a player has a session currently active.

  ## Examples

      Exmud.PlayerSession.active(:marie_curie)
  """
  def active(key) do
    {:ok, Registry.lookup(@registry, key) != []}
  end

  @doc """
  Send output to the player via its active session.

  A successful return from this function does not guarantee that the player has
  or will ever actually receive the output, only that the active player session
  process has accepted the output and will attempt to deliver the output as
  soon as possible.

  ## Examples

      Exmud.PlayerSession.send_output(:james_watson, "The Double Helix")
  """
  def send_output(key, output) do
    send_message(key, {:send_output, output})
  end

  @doc """
  Start a player new player session.

  An `Exmud.Player` must have been registered with the `key` prior to starting
  a session for said player.

  ## Examples

      Exmud.PlayerSession.start(:francis_crick)
  """
  def start(key) do
    if Player.exists(key) == {:ok, true} do
      {:ok, _pid} = Supervisor.start_child(PlayerSessionSup, [key])
      {:ok, :success}
    else
      {:error, :no_such_player}
    end
  end


  @doc """
  Stop an active player session.

  ## Examples

      Exmud.PlayerSession.stop(:robert_boyle)
  """
  def stop(key) do
    send_message(key, :stop)
  end


  @doc """
  Stream all output sent through an active player session through the provided
  handler function.

  The handler function should be as simple as possible, ideally doing no more
  than acting as a proxy that determines where and in what format the message
  is sent.

  ## Examples

      Exmud.PlayerSession.stream_output(:ada_lovelace, &(send_message_somewhere(&1, destination))
  """
  def stream_output(key, handler_fun) do
    send_message(key, {:stream_output, handler_fun})
  end


  #
  # Worker callback
  #


  @doc false
  def start_link(key), do: GenServer.start_link(__MODULE__, :ok, name: via_tuple(@registry, key))


  #
  # GenServer Callbacks
  #


  @doc false
  def init(key) do
    {:ok, pid} = GenEvent.start_link([])
    {:ok, %State{event_manager: pid, key: key, start_time: Calendar.DateTime.now_utc()}}
  end

  @doc false
  def handle_call(:stop, _from, state) do
    {:stop, :normal, :ok, state}
  end

  @doc false
  def handle_call({:send_output, output}, _from, state) do
    if GenEvent.which_handlers(state.event_manager) != [] do
      :ok = GenEvent.notify(state.event_manager, output)
      {:reply, :ok, state}
    else
      {:reply, :ok, %{state | message_queue: EQueue.push(state.message_queue, output)}}
    end
  end

  @lint {Credo.Check.Refactor.PipeChainStart, false}
  def handle_call({:stream_output, handler_fun}, _from, state) do
    :ok = GenEvent.add_handler(state.event_manager, PlayerSessionOutputHandler, handler_fun)

    if EQueue.length(state.message_queue) > 0 do
      EQueue.to_list(state.message_queue)
      |> Enum.each(&(:ok = GenEvent.notify(state.event_manager, &1)))
    end

    {:reply, :ok, %{state | message_queue: EQueue.new()}}
  end


  #
  # Private Functions
  #


  defp send_message(key, message) do
    case active(key) do
      {:ok, false} -> {:error, :no_session_active}
      {:ok, true} ->
        via = via_tuple(@registry, key)
        :ok = GenServer.call(via, message)
        {:ok, :success}
    end
  end
end
