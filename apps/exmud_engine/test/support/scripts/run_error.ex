defmodule Exmud.Engine.Test.Script.RunError do
  use Exmud.Engine.Script

  def run(_object_id, state) do
    {:error, :error, state}
  end
end