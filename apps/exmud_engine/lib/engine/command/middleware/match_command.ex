defmodule Exmud.Engine.Command.Middleware.MatchCommand do
  @moduledoc """
  This default implementation considers the caller to be the whole context, doing nothing more than building the active list of Commands from that.
  """

  alias Exmud.Engine.Command

  @behaviour Exmud.Engine.Command.Middleware

  def execute(execution, command_index \\ nil) do
    input = execution.raw_input
    commands = execution.command_list

    case match_commands(input, commands) do
      [command] ->
        {:ok, %{execution | owner: command.object_id,
                            matched_command: command.callback_module,
                            matched_key: command.key}}
      multipleCommands ->
        if command_index != nil do
          command = Enum.at(multipleCommands, command_index)

          {:ok, %{execution | owner: command.object_id,
                              matched_command: command.callback_module,
                              matched_key: command.key}}
        else
          # save multimatch data on caller
          # add MultiMatch component
          # save all matched commands to the MultiMatch component
          # Add command set on Caller for the multiple commands
          #   Is this going to need to be a dynamically generated command set with dynamically generated commands?
          #     No, should be a single hardcoded command set and dynamically generated message to the player that outlines the various options that can be taken. It should be a very high priority command set that replaces all others (in almost every case) containing a single command which matches any number passed to it and which pulls the previously saved commands out of the DB and selects the correct one to execute.
          #     If the number doesn't match, leave the command set in place. If it does match remove command set, and then remove component/data from caller
          {:ok, %{execution | matched_command: Exmud.Engine.Command.MultiMatchError}}
        end
    end
  end

  defp match_commands(input, commands) do
    do_match(input, commands, [])
  end

  defp do_match(_, [], matched_commands) do
    matched_commands
  end

  defp do_match(input, [command | commands], matched_commands) do
    regex = command.callback_module.argument_regex()
    key_and_aliases = List.wrap(command.callback_module.key) ++ command.callback_module.aliases

    case Enum.find(key_and_aliases, &(String.starts_with?(input, &1))) do
      nil ->
        do_match(input, commands, matched_commands)
      match ->
        arg_string = List.last(String.slice(input, String.length(match)))
        if Regex.match?(regex, arg_string) do
          do_match(input, commands, [command | matched_commands])
        else
          do_match(input, commands, matched_commands)
        end
    end
  end
end
