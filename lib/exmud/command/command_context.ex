defmodule Exmud.CommandContext do
  @moduledoc """
  The first step in processing a command string is to gather the command sets together, but to do that
  """

  @typedoc "The command string to be parsed."
  @type command_string :: String.t


  @doc """
  Run the preprocessor on the passed in command string.

  The intention is that these preprocessors should be able to be mixed and matched transparently to each other, to the
  engine, and to the command callback module which will eventually process the command string. To that effect, this
  callback function takes in a string and returns a string.

  An example use case would be for universal command aliases, where a `'` prefix might be transformed into the string
  `say ` so the engine can match the correct command. For example, the player might enter `'Hello!` which would likely
  not match any command registered. To make sure the input is mapped to the correct command, a preprocessor might spit
  out the string `say Hello!` which would then match against a `say` command.
  """
  @callback run(command_string) :: command_string
end
