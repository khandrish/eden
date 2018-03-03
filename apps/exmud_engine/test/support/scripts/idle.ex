defmodule Exmud.Engine.Test.Script.Idle do
  use Exmud.Engine.Script

  def initialize(__object_id, _args) do
    {:ok, :crypto.strong_rand_bytes(1024)}
  end
end