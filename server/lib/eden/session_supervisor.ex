defmodule Eden.SessionSupervisor do
  use Supervisor

  #
  # API
  #

  def start_child do
    Supervisor.start_child(:ok, [])
  end

  def start_link do
    Supervisor.start_link(__MODULE__, :ok)
  end

  #
  # GenServer callbacks
  #

  def init(:ok) do
    children = [
      worker(Eden.Session, [])
    ]

    supervise(children, strategy: :simple_one_for_one)
  end
end
