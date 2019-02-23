defmodule Exmud.Game.Contributions.Core.Command.NoMatch do
  @moduledoc """
  This system Command is invoked when no matches have been made while processing an input string.

  A message is sent to the Player.
  """

  use Exmud.Engine.Command

  @impl true
  def doc_generation( _config ), do: false

  @impl true
  def execute( execution_context ) do
    # Add message to player, via calling Object, to execution context

    execution_context
  end

  @impl true
  def key( _config ), do: "CMD_NO_MATCH"
end
