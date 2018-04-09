defmodule Exmud.Engine.Test.Script.RunInterval do
  use Exmud.Engine.Script

  def run(_object_id, _) do
    {:ok, :ok, 60_000}
  end
end