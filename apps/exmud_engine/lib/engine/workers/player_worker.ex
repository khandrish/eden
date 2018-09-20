defmodule Exmud.Engine.PlayerWorker do
  @moduledoc false

  use GenServer
  alias Exmud.Engine.Player
  import Exmud.Engine.Constants

  @player_registry player_registry()

  defmodule State do
    @enforce_keys [ :object_id, :player_name ]
    defstruct [
      :object_id,
      :player_name
    ]
  end


  #
  # Worker callback used by the supervisor when starting a new Script Runner.
  #

  @doc false
  @spec child_spec( args :: term ) :: { :ok, map() }
  def child_spec( args ) do
    %{
      id: __MODULE__,
      start: { __MODULE__, :start_link, args },
      restart: :transient,
      shutdown: 1000,
      type: :worker
    }
  end

  @impl true
  def init( player_name ) do
    object_id = Player.get_player( player_name )
    send self(), :start_scripts
    { :ok, %State{ object_id: object_id, player_name: player_name } }
  end

  @impl true
  def handle_info( :start_scripts, _from, state ) do
    # start all scripts belonging to player object
    { :no_reply, state }
  end

  @impl true
  def handle_cast( { :push, item }, state ) do
    { :noreply, [ item | state ] }
  end
end
