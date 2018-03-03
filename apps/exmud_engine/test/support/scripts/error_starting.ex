defmodule Exmud.Engine.Test.Script.ErrorStarting do
  use Exmud.Engine.Script

  def start(_, _, state), do: {:error, "error", state}
end