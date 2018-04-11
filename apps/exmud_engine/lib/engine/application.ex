defmodule Exmud.Engine.Application do
  @moduledoc false

  import Exmud.Engine.Utils
  use Application

  def start(_type, _args) do
    children = [
      Exmud.Engine.Repo,
      %{
        id: Cachex,
        start: {Cachex, :start_link, [cache()]}
      },
      {Registry, keys: :unique, name: system_registry()},
      {Registry, keys: :unique, name: script_registry()},
      {DynamicSupervisor, strategy: :one_for_one, name: Exmud.Engine.CallbackSupervisor}
    ]

    Supervisor.start_link(children, strategy: :one_for_one)
  end
end
