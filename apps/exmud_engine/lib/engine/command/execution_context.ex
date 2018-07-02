defmodule Exmud.Engine.Command.ExecutionContext do
  @moduledoc """
  An ExecutionContext struct contains everything required for the processing of a Command.
  """

  defstruct [
    :args, # Parsed arguments for the command.
    :caller, # Object that is doing the calling. All Commands are executed by Objects, even if triggered by a Player.
    {:data, %{}}, # Arbitrary data that can be set and used from any of the middlewares.
    :command_set, # Final merged Active Command Set which is used for matching.
    :matched_command, # The command which was actually matched. This is the callback module which implements the logic.
    :matched_key, # Key that actually matched. For 'move west' the matched_key would be 'move'.
    {:events, []}, # Events to be executed as part of the pipeline. It is, by default, executed after a Command has run.
    :owner, # The Object the matched command belongs to. Does not have to be the caller, and often won't be.
    :pipeline_steps, # The results of the pipeline middlewares that have been executed.
    :raw_input # The raw text input before any processing.
  ]

  def get(context, key) do
     Map.get(context.data, key)
  end

  def has_key?(context, key) do
     Map.get_key?(context.data, key)
  end

  def put(context, key, value) do
    {context | data: Map.put(context.data, key, value)}
  end
end

defimpl String.chars, for: Exmud.Engine.Command.ExecutionContext do
  def string(execution) do
    "%{args: <masked>, caller: '#{execution.caller}', command_set: <masked>" <>
    ", matched_command: '#{execution.matched_command}', matched_key: '#{execution.matched_key}'" <>
    ", messages: <masked>, owner: '#{execution.owner}', raw_input: '#{raw_input}'}"
  end
end
