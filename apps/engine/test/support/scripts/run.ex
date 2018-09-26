defmodule Exmud.Engine.Test.Script.Run do
  use Exmud.Engine.Script

  def run(_object_id, _state) do
    {:ok, :totally_unique_state}
  end
end
