defmodule Eden.Engine do
  use GenServer
  use Phoenix.Channel

  alias Eden.EntityManager, as: EM

  # API
  def start_link do
  	GenServer.start_link(__MODULE__, nil, name: :engine)
  end

  def start do
    GenServer.call(:engine, :start)
  end

  def stop do
    GenServer.call(:engine, :stop)
  end

  # Callbacks
  def init(_input) do
    EM.create_caches
  	{:ok, %{cache_primed: false, state_entity: nil}}
  end

  def handle_call(:start, _from, %{cache_primed: false} = state) do
    EM.load_all_entities
    [id] = EM.get_entities_with_component("world state")
    start_engine(id)
    {:reply, :ok, %{state | :cache_primed => true, :state_entity => id}}
  end

  def handle_call(:start, _from, state) do
    start_engine(id)
    {:reply, :ok, state}
  end

  def handle_call(:stop, _from, state) do
    {:reply, :ok, state}
  end

  #
  # Private Functions
  #

  defp start_engine(state_entity) do
    # update the time
    # how will time in the game work?
    # time should pass at a fixed rate compared to real time
    # time should break down in a reasonably understandable way that in some way corresponds with real time
    # 1 IG day = 5 RL hours
    # 1 IG day = 30 IG hours
    # 6 IG hours = 1 RL hour
    # 1 IG hour = 10 RL minutes
    # 1/2 IG hour = 5 RL minutes
    # 1/10 IG hour = 1 RL minute

    # need to be able to translate seconds passing in real time to in game time
    # need to be able to set the exact time the engine should use to begin its calculations
    # need to be able to set the starting time down to at least hour granularity
    # taking the starting times, dynamically calculate what time it is at the moment of request

    # need to be able to generate offsets
  end
end
