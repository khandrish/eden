defmodule Exmud.Engine.Test.CommandSet.HighPriority do
  use Exmud.Engine.CommandSet

  @impl true
  def commands(_config), do: [ Exmud.Engine.Test.Command.Echo, Exmud.Engine.Test.Command.Ghost ]

  @impl true
  def merge_priority(_config), do: 10
end
