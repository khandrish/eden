defmodule Exmud.PlayerSession do
  alias Exmud.PlayerSessionOutputHandler
  alias Exmud.Registry
  
  
  #
  # Worker callback
  #
  
  
  @doc false
  def start_link(player, args) do
    GenServer.start_link(__MODULE__, {player, args})
  end


  #
  # GenServer Callbacks
  #


  def init({name, _args}) do
    true = Registry.register_name(name)
    {:ok, pid} = GenEvent.start_link([])
    {:ok, %{name: name, event_manager: pid}}
  end

  def handle_call({:stream_output, handler_fun}, {process, _}, %{event_manager: pid} = state) do
    {:reply, GenEvent.add_handler(pid, PlayerSessionOutputHandler, handler_fun), state}
  end

  def handle_call({:send_output, output}, _from, %{event_manager: pid} = state) do
    :ok = GenEvent.notify(pid, output)
    {:reply, :ok, state}
  end

  def handle_call({:stop, _args}, _from, state) do
    {:stop, :normal, :ok, state}
  end

  def terminate(_reason, %{name: name} = _state) do
    Registry.unregister_name(name)
  end
end