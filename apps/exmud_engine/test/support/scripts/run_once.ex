defmodule Exmud.Engine.Test.Script.RunOnce do
  use Exmud.Engine.Script

  def run(_object_id, _) do
    {:ok, :ok}
  end
end