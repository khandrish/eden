defmodule Exmud.Engine.Test.Script.Run do
  use Exmud.Engine.Script

  def initialize(__object_id, _args) do
    {:ok, 0}
  end

  def run(_object_id, 0) do
    {:ok, 1}
  end

  def run(_object_id, 1) do
    {:ok, 2, 0}
  end

  def run(_object_id, 2) do
    {:error, "error", 3, 0}
  end

  def run(_object_id, 3) do
    {:error, "error", 4}
  end

  def run(_object_id, 4) do
    {:stop, "because", 5}
  end

  def run(_object_id, 6) do
    {:stop, "because", 7}
  end

  def stop(_, _, 5), do: {:ok, 6}

  def stop(_, _, 7), do: {:error, "error", 6}
end