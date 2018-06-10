defmodule Exmud.Engine.Command.ExecutionContext do
  @moduledoc """
  An ExecutionContext struct contains everything required for the processing of a Command.
  """

  defstruct [
    :args, # Parsed arguments for the command.
    :caller, # Object that is doing the calling. All Commands are executed by Objects, even if triggered by a Player.
    {:data, %{}},
    :command_set, # Final merged Active Command Set which is used for matching.
    :matched_command, # The command which was actually matched. This is the callback module which implements the logic.
    :matched_key, # Key that actually matched. For 'move west' the matched_key would be 'move'.
    {:messages, []}, # Outgoing messages to be sent after a successful execution.
    :owner, # The Object the matched command belongs to.
    :raw_input # The raw input before any processing.
  ]
end

defimpl String.chars, for: Exmud.Engine.Command.ExecutionContext do
  def string(execution) do
    "%{args: <masked>, caller: '#{execution.caller}', command_set: <masked>" <>
    ", matched_command: '#{execution.matched_command}', matched_key: '#{execution.matched_key}'" <>
    ", messages: <masked>, owner: '#{execution.owner}', raw_input: '#{raw_input}'}"
  end
end
