defmodule Exmud.Command.Transformer.SayPrefixAlias do
  @moduledoc """
  If present, replaces a `'` at the beginning of a string with the string `say ` to facilitate command matching.
  """

  @behaviour Exmud.Command.Transformer

  @doc false
  def transform(command_string) do
    command_string
    |> String.replace_prefix("'", "say ")
    |> String.replace_prefix("\"", "say ")
  end
end
