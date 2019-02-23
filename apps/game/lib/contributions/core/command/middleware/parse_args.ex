defmodule Exmud.Game.Contributions.Core.Command.Middleware.ParseArgs do
  @moduledoc """
  The arg string, which is everything after the matched command, should be processed before the Command is executed.
  """

  @behaviour Exmud.Engine.Command.Middleware

  def execute(execution_context) do
    command = execution_context.matched_command
    command.parse_args.(execution_context)
  end
end
