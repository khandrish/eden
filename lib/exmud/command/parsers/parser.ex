defmodule Exmud.Command.Parser do
  @moduledoc """
  A processor is responsible for the end-to-end parsing of string input into a more suitable form for processing.

  In a simple case it means an arg string `/happy Hello World!`, from the input string `say /happy Hello World!`, could
  be turned into `%{message: "Hello World!", tone: "happy"}` which would be passed to a handler for processing.
  """

  @typedoc "The command string to be parsed."
  @type arg_string :: String.t


  @doc """
  Parse the arg string and return a term which is passed into a handler.
  """
  @callback parse(arg_string) :: {:ok, term} | {:error, term}
end