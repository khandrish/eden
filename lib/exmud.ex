defmodule Exmud do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      supervisor(Task.Supervisor, [[name: Exmud.TaskSupervisor]]),
      supervisor(Exmud.PlayerSessionSup, []),
      supervisor(Exmud.SystemSup, [])
    ]

    opts = [strategy: :one_for_one, name: Exmud.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
