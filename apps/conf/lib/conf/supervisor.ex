defmodule Conf.Supervisor do
  @moduledoc false

  use Supervisor

  def start_link() do
    Supervisor.start_link(__MODULE__, :ok)
  end

  def init(:ok) do
    Conf = :ets.new(Conf, [:set, :public, :named_table, read_concurrency: true])

    supervise([], strategy: :one_for_one)
  end
end
