defmodule Exmud.Command.Preproccessor.TrimTrailing do
  @moduledoc """
  Trims trailing spaces on the command string.
  """

  @behaviour Exmud.Command.Preproccessor

  @doc false
  def run(command_string), do: String.trim_trailing(command_string)
end