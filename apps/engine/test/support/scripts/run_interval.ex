defmodule Exmud.Engine.Test.Script.RunInterval do
  use Exmud.Engine.Script

  def run(_object_id, state) do
    {:ok, state, 60_000}
  end
end
