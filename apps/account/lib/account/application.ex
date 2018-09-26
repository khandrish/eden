defmodule Exmud.Player.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      worker(Exmud.Player.Repo, [])
    ]

    opts = [strategy: :one_for_one, name: Exmud.Player.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
