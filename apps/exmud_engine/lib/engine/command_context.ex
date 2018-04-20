defmodule Exmud.Engine.CommandContext do
  @moduledoc """
  The context passed to a Commands execute callback. Contains everything required for the Command to start its
  execution.
  """
  defstruct owner: nil, caller: nil, match_string: nil, args: nil, raw_input: nil, active_command_set: nil
end