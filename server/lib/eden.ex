defmodule Eden do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      supervisor(Eden.Endpoint, []),
      worker(Eden.Repo, []),
      worker(Eden.Engine, []),
      worker(ConCache, [[], [name: :data_cache]]),
      supervisor(Eden.SessionSupervisor, [])
    ]

    pools = Enum.map(pools(), fn({name, args}) ->
        pool_options = [name: {:local, name},
                     worker_module: args.worker_module,
                     size: args.size,
                     max_overflow: args.max_overflow]
        :poolboy.child_spec(name, pool_options, [])
      end)

    opts = [strategy: :one_for_one, name: Eden.Supervisor]
    Supervisor.start_link(children ++ pools, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    Eden.Endpoint.config_change(changed, removed)
    :ok
  end

  defp pools do
    Application.get_env(:eden, :pools)
  end
end
