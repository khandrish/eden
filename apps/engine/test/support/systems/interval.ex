defmodule Exmud.Engine.Test.System.Interval do
  @moduledoc """
  A barebones example of a system that uses intervals when starting and running.
  """

  use Exmud.Engine.System

  @interval 5

  def start(_object_id, _args, state), do: {:ok, state, @interval}

  def run(_object_id, state), do: {:ok, state, @interval}
end
