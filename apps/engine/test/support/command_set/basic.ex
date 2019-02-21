defmodule Exmud.Engine.Test.CommandSet.Basic do
  use Exmud.Engine.CommandSet

  @impl true
  def commands(_config), do: [Exmud.Engine.Test.Command.Echo, Exmud.Engine.Test.Command.Ghost]
end
