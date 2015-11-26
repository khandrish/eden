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
    options = [:named_table, :public]
    :ets.new(:entity_cache, options)
    options = [:named_table, :bag, :public]
    :ets.new(:component_entity_index, options)
    :ets.new(:component_key_entity_index, options)
    :ets.new(:entity_component_index, options)
    :ets.new(:entity_component_key_index, options)
  	{:ok, %{}}
  end

  def handle_call(:start, _from, state) do
    {:noreply, :ok, state}
  end

  def handle_call(:stop, _from, state) do
    {:reply, :ok, state}
  end
end