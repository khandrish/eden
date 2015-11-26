defmodule Eden do
  use Application

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      # Start the endpoint when the application starts
      supervisor(Eden.Endpoint, []),
      # Start the Ecto repository
      worker(Eden.Repo, []),
      # Here you could define other workers and supervisors as children
      worker(Eden.Engine, [])
    ]

    pools = Enum.map(pools(), fn({name, args}) ->
        pool_options = [name: {:local, name},
                     worker_module: args.worker_module,
                     size: args.size,
                     max_overflow: args.max_overflow]
        :poolboy.child_spec(name, pool_options, [])
      end)

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
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
