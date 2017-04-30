defmodule Exmud.Command.Context do
  @moduledoc """
  The first step in processing a command string is to gather the command sets together that will be used to calculate
  the final command set which will the command string will be matched against.

  As the engine has no knowledge of game implementation this responsibility has to be passed back to the consuming
  application via a callback module. Since there can be only one of these callbacks, it can be configured like so:
  ```
  config :exmud, :engine,
    command_context_callback: UniqueMud.ContextCallback
  ```
  """

  @typedoc "The id of the object which the command is being executed on behalf of."
  @type subject :: object

  @typedoc "The id of an object."
  @opaque object :: term


  @doc """
  Gather the context, the set of objects, which the command sets will be gathered from and return the ids.
  """
  @callback run(subject) :: [object]
end
