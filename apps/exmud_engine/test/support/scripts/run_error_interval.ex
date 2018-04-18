defmodule Exmud.Engine.Test.Script.RunErrorInterval do
  use Exmud.Engine.Script

  def run(_object_id, state) do
    {:error, :error, state, 60_000}
  end
end
