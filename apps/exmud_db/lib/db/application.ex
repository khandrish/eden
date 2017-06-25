defmodule Exmud.DB.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      worker(Exmud.DB.Repo, [])
    ]

    opts = [strategy: :one_for_one, name: Exmud.DB.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
