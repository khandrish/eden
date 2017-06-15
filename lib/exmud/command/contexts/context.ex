defmodule Exmud.Command.Context do
  @moduledoc """
  To calculate the commands against which to match the command string, the caller's context must be defined. This
  context is a list of object id's from which to pull command sets from for merger and command matching.

  As the engine has no knowledge of game implementation this responsibility has to be passed back to the consuming
  application via a callback module. The engine will first check the calling object for a context callback and if one
  exists it will be used, otherwise a global callback will be fallen back to.

  To register a global context (Like the Highlander, there can be only one.):
  ```
  Exmud.Callback.register("command_context", MyGame.UniqueContext)
  ```

  To register an object specific context (One per object.):
  ```
  Exmud.Object.add_callback(object_id, "command_context", MyGame.UniqueContext)
  ```
  """

  @typedoc "The id of an object."
  @opaque object :: term


  @doc """
  Define the context, the set of objects, which the command sets will be gathered from and return the ids.
  """
  @callback define(object) :: [object]
end
