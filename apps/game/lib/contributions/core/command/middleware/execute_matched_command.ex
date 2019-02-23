defmodule Exmud.Game.Contributions.Core.Command.Middleware.ExecuteMatchedCommand do
  @moduledoc """
  The matched command, after all of the prepatory work has been completed, can finally be executed.
  """

  @behaviour Exmud.Engine.Command.Middleware

  def execute( execution_context ) do
    command = execution_context.matched_command
    command.execute.( execution_context )
  end
end
