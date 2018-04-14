defmodule Exmud.Engine.Test.Script.RunErrorStop do
  use Exmud.Engine.Script

  def initialize(_object_id, state), do: {:ok, state}

  def run(_object_id, state) do
    {:stop, :error, state}
  end
end