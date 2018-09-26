defmodule Exmud.Engine.Command.Middleware.FilterSystemCommands do
  @moduledoc """
  This middleware prevents system commands from being sent as input. Any system command is mapped to a no match error.
  """

  @behaviour Exmud.Engine.Command.Middleware

  alias Exmud.Engine.Command.NoMatch
  import Exmud.Engine.Constants

  def execute( execution_context ) do
    if Regex.match?( system_command_prefix(), execution_context.raw_input ) do
      { :ok, %{ execution_context | raw_input: NoMatch.key( nil ) } }
    else
      { :ok, execution_context }
    end
  end
end
