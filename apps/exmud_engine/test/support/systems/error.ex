defmodule Exmud.Engine.Test.System.ErrorStarting do
  @moduledoc """
  A barebones example of a system that idles after handling messages and running.
  """
  use Exmud.Engine.System

  def start(_object_id, _, _), do: {:error, :error, :ok}
end