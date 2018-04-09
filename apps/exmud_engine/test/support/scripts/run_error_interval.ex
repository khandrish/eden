defmodule Exmud.Engine.Test.Script.RunErrorInterval do
  use Exmud.Engine.Script

  def run(_object_id, _) do
    {:error, :error, :ok, 60_000}
  end
end