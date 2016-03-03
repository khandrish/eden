defmodule Eden.Session do
  use GenServer

  #
  # API
  #

  def start do
    Supervisor.start_child(Eden.SessionSupervisor, [Ecto.UUID.generate])
  end

  def start_link(token) do
    GenServer.start_link(__MODULE__, token, [])
  end

  #
  # GenServer callbacks
  #

  def init(token) do
    {:ok, %{token => token}}
  end
end
