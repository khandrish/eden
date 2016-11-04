defmodule Exmud.PlayerSup do
  require Logger
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, :ok,  name: __MODULE__)
  end

  def start_player(name) do
    Logger.debug("Starting child with name `#{name}`")
    Supervisor.start_child(__MODULE__, [name])
  end

  def init(_) do
    children = [
      worker(Exmud.Player, [])
    ]

    supervise(children, strategy: :simple_one_for_one)
  end
end
