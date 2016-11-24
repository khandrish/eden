defmodule Exmud.PlayerSessionSup do
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, :ok,  name: __MODULE__)
  end

  def init(_) do
    children = [
      worker(Exmud.PlayerSession, [], restart: :transient)
    ]

    supervise(children, strategy: :simple_one_for_one)
  end
end
