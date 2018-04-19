defmodule Exmud.Engine.Test.CommandSet.Basic do
  use Exmud.Engine.CommandSet

  @impl true
  def commands(_config), do: ["foo"]
end
