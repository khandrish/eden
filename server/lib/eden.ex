defmodule Eden do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      supervisor(Eden.Endpoint, []),
      worker(Eden.Repo, []),
      worker(Eden.Engine, []),
      worker(ConCache, [[], [name: :data_cache]])
    ]

    opts = [strategy: :one_for_one, name: Eden.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    Eden.Endpoint.config_change(changed, removed)
    :ok
  end
end
