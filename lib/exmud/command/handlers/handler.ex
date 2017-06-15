defmodule Exmud.Command.Handler do
  @moduledoc """
  A handler is where the custom command logic resides.

  At this point the correct command has been found, the arg string has been successfully parsed, and all that is left
  is to execute the logic of the command.
  """

  @typedoc "The command string to be parsed."
  @type command_string :: String.t


  @doc """
  Given the provided arguments, do all the things.
  """
  @callback handle(command_string) :: {:ok, term} | {:error, term}
end