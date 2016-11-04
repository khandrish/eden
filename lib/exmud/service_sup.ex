defmodule Exmud.ServiceSup do
  require Logger
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, :ok,  name: __MODULE__)
  end

  def start_service(service, args) do
    Logger.debug("Starting service: `#{service}`")
    Supervisor.start_child(__MODULE__, [service, args])
  end

  def init(:ok) do
    children = [
      worker(Exmud.ServiceRunner, [])
    ]

    supervise(children, strategy: :simple_one_for_one)
  end
end
