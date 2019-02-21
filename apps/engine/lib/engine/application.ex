defmodule Exmud.Engine.Application do
  @moduledoc false

  import Exmud.Engine.Constants
  use Application

  def start(_type, _args) do
    children = [
      Exmud.Engine.Repo,
      {Registry, keys: :unique, name: system_registry()},
      {Registry, keys: :unique, name: script_registry()},
      {DynamicSupervisor, strategy: :one_for_one, name: Exmud.Engine.CallbackSupervisor},
      {DynamicSupervisor, strategy: :one_for_one, name: Exmud.Engine.CommandSupervisor}
    ]

    Supervisor.start_link(children, strategy: :one_for_one)
  end
end
