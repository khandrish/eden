defmodule Exmud.Engine.Test.Script.Idle do
  use Exmud.Engine.Script

  def initialize(__object_id, args) do
    {:ok, args}
  end
end