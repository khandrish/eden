defmodule Exmud.Command.Preproccessor.TrimLeading do
  @moduledoc """
  Trims leading spaces on the command string.
  """

  @doc false
  def run(command_string), do: String.trim_leading(command_string)
end
