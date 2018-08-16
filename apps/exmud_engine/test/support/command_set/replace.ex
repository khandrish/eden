defmodule Exmud.Engine.Test.CommandSet.Replace do
  use Exmud.Engine.CommandSet

  @impl true
  def commands(_config), do: [ Exmud.Engine.Test.Command.Ghost ]

  @impl true
  def merge_type(_config), do: :replace
end
