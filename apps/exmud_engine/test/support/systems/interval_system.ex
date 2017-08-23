defmodule Exmud.Engine.Test.System.Interval do
  @moduledoc """
  A barebones example of a system that uses intervals when starting and running.
  """

  use Exmud.Engine.Test.System

  @interval 5

  def start(_args, state), do: {:ok, state, @interval}

  def run(state), do: {:ok, state, @interval}
end