defmodule Exmud.Game.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      worker(Exmud.Game.MasterControlProgram, [])
    ]

    opts = [strategy: :one_for_one, name: Exmud.Game.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
