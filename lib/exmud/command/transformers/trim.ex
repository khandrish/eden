defmodule Exmud.Command.Transformer.Trim do
  @moduledoc """
  Trims all unicode whitespace at the beginning and end of the command string.
  """

  @behaviour Exmud.Command.Transformer

  @doc false
  def transform(command_string), do: String.trim(command_string)
end
