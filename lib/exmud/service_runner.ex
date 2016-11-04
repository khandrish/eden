defmodule Exmud.ServiceRunner do
  @moduledoc false

  use GenServer

  def call(service, message) do

  end

  def cast(service, message) do

  end

  def deregister(service, args) do

  end

  def register(service, args) do
    Exmud.ServiceSup.start_service(service, args)
  end

  def start(service, args) do
    Process.whereis(service)
    |> GenServer.call({:start, args})
  end

  def stop(service, args) do
    Process.whereis(service)
    |> GenServer.call({:stop, args})
  end

  def start_link({service, args}, _opts) do
    GenServer.start_link(__MODULE__, args, [name: service])
  end

  def init(args) do
    #{:ok, state} = service.init(args)

    {:ok, %{}}
  end

  def handle_call(_msg, _from, state) do
    {:reply, :ok, state}
  end

  def handle_cast(_msg, state) do
    {:noreply, state}
  end
end
