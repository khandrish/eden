defmodule Exmud.Engine.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      worker(Exmud.Engine.Cache, [])
    ]

    opts = [strategy: :one_for_one, name: Exmud.Engine.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
