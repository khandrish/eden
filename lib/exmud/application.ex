defmodule Exmud.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    # List all child processes to be supervised
    children = [
      # Start the Ecto repository
      Exmud.Repo,
      # Start the endpoint when the application starts
      ExmudWeb.Endpoint,
      # For all of the configurable workers that need to be started up once a config is provided.
      {DynamicSupervisor, strategy: :one_for_one, name: Exmud.DynamicSupervisor},
      {Redix, name: :redix}
    ]

    opts = [strategy: :one_for_one, name: Exmud.Supervisor]
    {:ok, pid} = Supervisor.start_link(children, opts)

    openid_connect_providers =
      Enum.map(Application.get_env(:exmud, :openid_connect_providers, []), fn {provider, config} ->
        {provider,
         Keyword.put(
           config,
           :redirect_uri,
           ExmudWeb.Endpoint.url() <> "/auth/#{provider}/callback"
         )}
      end)

    Supervisor.start_child(Exmud.Supervisor, {OpenIDConnect.Worker, openid_connect_providers})

    {:ok, pid}
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    ExmudWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
