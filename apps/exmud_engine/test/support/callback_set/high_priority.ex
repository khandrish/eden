defmodule Exmud.Engine.Test.CallbackSet.HighPriority do
  use Exmud.Engine.CallbackSet

  @impl true
  def callbacks(_config), do: ["foobar"]

  @impl true
  def merge_priority(_config), do: 10
end
