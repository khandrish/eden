defmodule Exmud.Application do
  @moduledoc false

  use Application

  @spec start(any, any) :: {:error, {:already_started, pid}} | {:ok, pid}
  def start(_type, _args) do
    # List all child processes to be supervised
    children = [
      # Start the Ecto repository
      Exmud.Repo,
      # Start the endpoint when the application starts
      ExmudWeb.Endpoint,
      # For all of the configurable workers that need to be started up once a config is provided.
      {DynamicSupervisor, strategy: :one_for_one, name: Exmud.DynamicSupervisor},
      {Redix, name: :redix},
      Exmud.Vault
    ]

    opts = [strategy: :one_for_one, name: Exmud.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    ExmudWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
