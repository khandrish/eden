defmodule Exmud.Engine.Test.CallbackSet.Basic do
  use Exmud.Engine.CallbackSet

  @impl true
  def callbacks(_config), do: ["foo"]
end
