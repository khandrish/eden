defmodule Conf.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    Conf = :ets.new(Conf, [:set, :public, :named_table, read_concurrency: true])
    Supervisor.start_link(Conf.Supervisor, [], strategy: :one_for_one)
  end
end
