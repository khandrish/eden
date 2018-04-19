defmodule Exmud.Engine.Test.CommandSet.Replace do
  use Exmud.Engine.CommandSet

  @impl true
  def commands(_config), do: IO.inspect ["farboo"]

  @impl true
  def merge_type(_config), do: :replace
end
