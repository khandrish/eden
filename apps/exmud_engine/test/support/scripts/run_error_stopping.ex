defmodule Exmud.Engine.Test.Script.RunErrorStopping do
  use Exmud.Engine.Script

  def run(_object_id, _) do
    {:stop, :error, :ok}
  end

  def stop(_object_id, reason, _) do
    {:error, reason, :ok}
  end
end