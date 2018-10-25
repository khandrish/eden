defmodule Exmud.Game.Contributions.Command.Middleware.BuildActiveCommandList do
  @moduledoc """
  This default implementation considers the caller to be the whole context, doing nothing more than building the active list of Commands from it.

  This is a placeholder that should be replaced to enable any sort of complex functionality.
  """

  @behaviour Exmud.Engine.Command.Middleware

  alias Exmud.Engine.CommandSet

  def execute( execution_context ) do
    {
      :ok,
      %{
        execution_context
        | command_list:
            CommandSet.build_active_command_list(
              execution_context.caller,
              execution_context.caller
            )
      }
    }
  end
end
