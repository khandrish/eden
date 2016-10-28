defmodule Eden do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      supervisor(Task.Supervisor, [[name: Eden.TaskSupervisor]]),
      supervisor(Eden.PlayerSup, [])
    ]

    env = Application.get_env(:eden, :system_env, %{})
    
    systems = Application.get_env(:eden, :systems, [])
      |> Enum.map(&(worker(&1, [env])))

    opts = [strategy: :one_for_one, name: Eden.Supervisor]
    Supervisor.start_link(children ++ systems, opts)
  end
end
