defmodule Exmud.Application do
  @moduledoc false

  use Application
  import Ecto.Query

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
      {Redix, name: :redix}
    ]

    opts = [strategy: :one_for_one, name: Exmud.Supervisor]
    Supervisor.start_link(children, opts)
  end

  @spec start_phase(:init, any, any) :: :ok
  def start_phase(:init, _type, _) do
    now = DateTime.utc_now()

    callbacks =
      Elixir.Application.get_env(:exmud, :callback_modules, [])
      |> Enum.map(fn callback_args ->
        callback_args
        |> Keyword.put(:inserted_at, now)
        |> Keyword.put(:updated_at, now)
      end)

    callback_names =
      Enum.map(callbacks, fn callback -> Keyword.get(callback, :module) |> Atom.to_string() end)

    Exmud.Repo.delete_all(
      from(
        callback in Exmud.Builder.Callback,
        where: callback.module not in ^callback_names
      )
    )

    remaining_callbacks =
      Exmud.Repo.all(
        from(
          callback in Exmud.Builder.Callback,
          select: callback.module
        )
      )
      |> Enum.map(&Atom.to_string/1)

    filtered_callbacks =
      Enum.flat_map(callbacks, fn callback_args ->
        if Atom.to_string(Keyword.get(callback_args, :module)) in remaining_callbacks do
          []
        else
          [callback_args]
        end
      end)

    Exmud.Repo.insert_all(Exmud.Builder.Callback, filtered_callbacks)

    :ok
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    ExmudWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
