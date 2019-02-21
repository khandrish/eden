defmodule Exmud.Engine.Test.Command.Ghost do
  @moduledoc """
  This Command will never appear in the final set of Commands as it uses the 'None' lock which always fails.
  """
  use Exmud.Engine.Command

  @impl true
  def key(_context), do: "boo"

  @impl true
  def locks(_context), do: [Exmud.Engine.Lock.None]
end
