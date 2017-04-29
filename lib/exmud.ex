defmodule Exmud do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      supervisor(Task.Supervisor, [[name: Exmud.TaskSupervisor]]),
      supervisor(Registry, [:unique, :player_session_registry]),
      supervisor(Exmud.SystemSup, []),
      supervisor(Exmud.CommandProcessorSup, []),
      supervisor(Exmud.PlayerSessionSup, []),
      worker(Exmud.Repo, []),
      worker(Exmud.Registry, []),
    ]

    opts = [strategy: :one_for_one, name: Exmud.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
