defmodule Exmud.Engine.Application do
  @moduledoc false

  alias Exmud.Engine.Callback
  alias Exmud.Game.Schema
  import Exmud.Engine.Utils
  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      worker(Exmud.Engine.Repo, []),
      worker(Cachex, [cache(), []]),
      supervisor(Registry, [:unique, system_registry()]),
      supervisor(Exmud.Engine.SystemRunnerSupervisor, [])
    ]

    opts = [strategy: :one_for_one, name: Exmud.Engine.Supervisor]
    {:ok, _pid} = supervisor_result = Supervisor.start_link(children, opts)

    :ok = initialize_game_schema()

    supervisor_result
  end

  defp initialize_game_schema do
    Enum.each(Schema.callbacks, fn(callback) ->
      Callback.register(callback.key, callback.callback_function)
    end)
  end
end
