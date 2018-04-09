defmodule Exmud.Engine.Test.Script.RunError do
  use Exmud.Engine.Script

  def run(_object_id, _) do
    {:error, :error, :ok}
  end
end