defmodule Exmud.Command.Preproccessor.TrimTrailing do
  @moduledoc """
  Trims leading spaces on the command string.
  """

  def run(command_string), do: String.trim_trailing(command_string)
end
