defmodule Exmud.Session.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      worker(Exmud.Session.Repo, [])
    ]

    opts = [strategy: :one_for_one, name: Exmud.Session.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
