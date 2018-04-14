defmodule Exmud.Engine.Test.Script.Run do
  use Exmud.Engine.Script

  def run(_object_id, _state) do
    {:error, :error, :new_state}
  end
end