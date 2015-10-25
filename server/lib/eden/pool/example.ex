defmodule Eden.Pool.Example do
  use GenServer

  @pool_name :example

  # API

  def start_link(_) do
  	:gen_server.start_link(__MODULE__, %{}, [])
  end

  def start_session(token) do
  	worker = :poolboy.checkout(@pool_name)
  	active_session = GenServer.call(worker, {:start_session, token})
  	if active_session === worker do
  		:ok
  	else
  		:poolboy.checkin(worker)
  		:ok
  	end
  end

  def end_session(token) do
  	
  end

  def cleanup(worker) do
  	GenServer.call(worker, :cleanup)
  end

  def put do
  	worker = :poolboy.checkout(@pool_name)
  	GenServer.call(worker, {:put, "foo"})
  	:poolboy.checkin(@pool_name, worker)
  end

  # Callbacks

  def init(state) do
  	{:ok, state}
  end

  def handle_call({:echo, input}, _from, state) do
  	{:reply, input, state}
  end

  defp do_cleanup(_state) do
  	%{}
  end
end