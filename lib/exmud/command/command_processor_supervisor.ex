defmodule Exmud.CommandProcessorSup do
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, :ok,  name: __MODULE__)
  end

  def init(_) do
    children = [
      worker(Exmud.CommandProcessor, [], restart: :temporary)
    ]

    supervise(children, strategy: :simple_one_for_one)
  end
end
