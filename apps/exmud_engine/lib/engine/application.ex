defmodule Exmud.Engine.Application do
  @moduledoc false

  import Exmud.Engine.Utils
  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      worker(Exmud.Engine.Repo, []),
      worker(Cachex, [cache(), []]),
      Registry.child_spec([keys: :unique, name: system_registry()]),
      Registry.child_spec([keys: :unique, name: script_registry()]),
      supervisor(Exmud.Engine.SystemRunnerSupervisor, []),
      supervisor(Exmud.Engine.ScriptRunnerSupervisor, [])
    ]

    opts = [strategy: :one_for_one, name: Exmud.Engine.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
