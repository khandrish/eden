defmodule Exmud.SystemRunner do
  @moduledoc false

  alias Exmud.Registry
  alias Exmud.SystemFsm, as: Fsm
  use GenServer


  #
  # API
  #


  def call(system, message) do
    Registry.find_by_name(system)
    |> GenServer.call({:message, message})
  end

  def cast(system, message) do
    Registry.find_by_name(system)
    |> GenServer.cast({:message, message})
    system
  end

  def deregister(system) do
    Registry.find_by_name(system)
    |> GenServer.call(:terminate)

    system
  end

  def register(system, args) do
    {:ok, _} = Supervisor.start_child(Exmud.SystemSup, [system, args])
    system
  end

  def registered?(system) do
    Registry.name_registered?(system)
  end

  def running?(system) do
    Registry.find_by_name(system)
    |> GenServer.call(:running?)
  end

  def start(system, args) do
    Registry.find_by_name(system)
    |> GenServer.call({:start, args})
    system
  end

  def stop(system, args) do
    Registry.find_by_name(system)
    |> GenServer.call({:stop, args})
    system
  end

  def start_link(system, args) do
    GenServer.start_link(__MODULE__, {system, args}, [])
  end


  #
  # GenServer Callbacks
  #

  def init({system, args}) do
    Registry.register_name(system)
    system_fsm = Fsm.new
    |> Fsm.initialize(system, args)

    {:ok, system_fsm}
  end

  def handle_call(:running?, _from, system_fsm) do
    {:reply, Fsm.state(system_fsm) == :running, system_fsm}
  end

  def handle_call(:terminate, _from, system_fsm) do
    {:stop, :normal, :ok, Fsm.terminate(system_fsm)}
  end

  def handle_call({:start, args}, _from, system_fsm) do
    {:reply, :ok, Fsm.start(system_fsm, args)}
  end

  def handle_call({:stop, args}, _from, system_fsm) do
    {:reply, :ok, Fsm.stop(system_fsm, args)}
  end

  def handle_call({:message, message}, _from, system_fsm) do
    {response, system_fsm} = Fsm.message(system_fsm, message)
    {:reply, response, system_fsm}
  end

  def handle_cast({:message, message}, system_fsm) do
    {_response, system_fsm} = Fsm.message(system_fsm, message)
    {:noreply, system_fsm}
  end
end
