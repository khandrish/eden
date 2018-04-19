defmodule Exmud.Engine.Test.CallbackSet.Replace do
  use Exmud.Engine.CallbackSet

  @impl true
  def callbacks(_config), do: ["farboo"]

  @impl true
  def merge_type(_config), do: :replace
end
