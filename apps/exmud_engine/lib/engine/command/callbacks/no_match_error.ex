defmodule Exmud.Engine.Command.NoMatchError do
  @moduledoc """
  This system Command is invoked when no matches have been made while processing an input string.

  A message is sent to the Player.
  """

  use Exmud.Engine.Command

  @impl
  def doc_generation, do: false

  @impl
  def execute(execution_context) do
    # Add message to player via calling Object to execution context

    execution_context
  end

  @impl
  def key, do: "CMD_NO_MATCH"
end
