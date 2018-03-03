defmodule Exmud.Engine.Test.System.Idle do
  @moduledoc """
  A barebones example of a system that idles after handling messages and running.
  """
  use Exmud.Engine.System

  def name, do: "Idle"
end