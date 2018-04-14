defmodule Exmud.Engine.Test.Script.RunErrorStopping do
  use Exmud.Engine.Script

  def run(_object_id, state) do
    {:stop, :error, state}
  end

  def stop(_object_id, args, state) do
    {:error, args, state}
  end
end