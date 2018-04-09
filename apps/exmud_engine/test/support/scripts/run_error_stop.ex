defmodule Exmud.Engine.Test.Script.RunErrorStop do
  use Exmud.Engine.Script

  def run(_object_id, _) do
    {:stop, :error, :ok}
  end
end