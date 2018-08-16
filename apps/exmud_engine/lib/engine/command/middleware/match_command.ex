defmodule Exmud.Engine.Command.Middleware.MatchCommand do
  @moduledoc """
  The MatchCommand middleware is responsible for taking the already generated list of Commands along with the input and finding a matching Command.

  If more than one Command is matched, a MultiMatch Command will be used instead. This Command will be responsible for setting up the appropriate Command Set on the Object to allow for a choice to be made between the matching Commands.
  """

  import Exmud.Engine.Constants
  alias Exmud.Engine.Command.ExecutionContext

  @behaviour Exmud.Engine.Command.Middleware

  def execute ( execution_context ) do
    input = execution_context.raw_input
    commands = execution_context.command_list

    case match_commands( input, commands ) do
      [] ->
        {:ok, %{execution_context | matched_command: Exmud.Engine.Command.NoMatch}}
      [ command ] ->
        updated_data = Map.merge( execution_context.data, command.config )
        { :ok, %{ execution_context | owner: command.object_id,
                            matched_command: command,
                            matched_key: command.key,
                            data: updated_data,
                            raw_args: String.slice( input, String.length( command.key )..String.length( input ) ) } }
      multiple_commands ->
        execution_context = ExecutionContext.put(execution_context, command_multi_match_key(), multiple_commands)
        {:ok, %{execution_context | matched_command: Exmud.Engine.Command.MultiMatch}}
    end
  end

  defp match_commands(input, commands) do
    do_match(input, commands, [])
  end

  defp do_match(_, [], matched_commands) do
    matched_commands
  end

  defp do_match(input, [command | commands], matched_commands) do
    # When matching input to commands, the aliases should be checked along with the key
    key_and_aliases = [command.key | command.aliases]

    # Check the input string to see if it begins with a key or an alias
    case Enum.find(key_and_aliases, &(String.starts_with?(input, &1))) do
      nil ->
        do_match(input, commands, matched_commands)
      match ->
        # Extract the argument string from the rest of the input
        arg_string = String.slice(input, String.length(match)..String.length(input))
        regex = command.argument_regex()
        # Check to see if the argument string passes the regex check
        if Regex.match?(regex, arg_string) do
          do_match(input, commands, [command | matched_commands])
        else
          do_match(input, commands, matched_commands)
        end
    end
  end
end
