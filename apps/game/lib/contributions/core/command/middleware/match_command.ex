defmodule Exmud.Game.Contributions.Command.Middleware.MatchCommand do
  @moduledoc """
  The MatchCommand middleware is responsible for taking the already generated list of Commands along with the input and finding a matching Command.

  If more than one Command is matched, a MultiMatch Command will be used instead. This Command will be responsible for setting up the appropriate Command Set on the Object to allow for a choice to be made between the matching Commands.
  """

  import Exmud.Engine.Constants
  alias Exmud.Engine.Command.ExecutionContext

  @behaviour Exmud.Engine.Command.Middleware

  @system_command_multi_match engine_cfg( :system_command_multi_match )
  @system_command_no_match engine_cfg( :system_command_no_match )

  def execute ( execution_context ) do
    input = execution_context.raw_input
    commands = execution_context.command_list

    case match_commands( input, commands ) do
      [] ->
        { :ok, %{ execution_context | matched_command: @system_command_no_match } }
      [ command ] ->
        updated_data = Map.merge( execution_context.data, command.config )
        { :ok, %{ execution_context | owner: command.object_id,
                            matched_command: command,
                            matched_key: command.key,
                            data: updated_data,
                            raw_args: String.slice( input, String.length( command.key )..String.length( input ) ) } }
      multiple_commands ->
        execution_context = ExecutionContext.put( execution_context, command_multi_match_key(), multiple_commands )
        { :ok, %{ execution_context | matched_command: @system_command_multi_match } }
    end
  end

  defp match_commands( input, commands, matched_commands \\ [] )

  defp match_commands( _, [], matched_commands ) do
    matched_commands
  end

  defp match_commands( input, [ command | commands ], matched_commands ) do
    # When matching input to commands, the aliases should be checked along with the key
    key_and_aliases = [ command.key | command.aliases ]

    # Check the input string to see if it begins with a key or an alias
    case Enum.find( key_and_aliases, &( String.starts_with?( input, &1 ) ) ) do
      nil ->
        do_match( input, commands, matched_commands )
      match ->
        # Extract the argument string from the rest of the input
        arg_string = String.slice( input, String.length( match )..String.length( input ) )
        regex = command.argument_regex()
        # Check to see if the argument string passes the regex check
        if Regex.match?( regex, arg_string ) do
          match_commands( input, commands, [ command | matched_commands ] )
        else
          match_commands( input, commands, matched_commands )
        end
    end
  end
end
