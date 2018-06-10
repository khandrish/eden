defmodule Exmud.Engine.Command.Middleware do
  @moduledoc """
  Middleware is responsible for every stage of processing a Command.

  By specifying `@behaviour Exmud.Engine.Command.Middleware` the compiler will ensure that a `def execute` callback has been provided. The function takes an `%Exmud.Engine.Command.Execution{}` struct as the only argument and expects an updated struct or an error tuple in return.

  See 'Exmud.Engine.Command.Execution' for further details.

  Middleware can be configurd for use in a couple of ways:

  1. Override the default command processing pipeline configuration.
  2. Use the `middleware/2` callback in a Command callback module to modify the pipeline at runtime.
  3. Provide an override pipeline on execution of a Command, which will still be subject to #2 above.

  ## Configuration

  Overriding the pipeline via config changes how every command is processed. Check the existing config before overriding to ensure critical steps in the pipeline are not missed.

  Note: The override should be done in the exmud_game application and not the exmud_engine application. The default pipeline should be left as is in case of future updates so there aren't constant git conflicts.

  Example:

  ```
  alias Exmud.Game.Command.Middleware

  config :exmud_engine, :command,
    pipeline: [
      Middleware.BuildActiveCommandSet,
      Middleware.MatchCommand,
      Middleware.ExecuteCommand,
      Middleware.SendMessages
    ]
  ```

  ## The `middleware/2` callback.

  `middleware/2` is a callback function on a Command callback module. When using `Exmud.Engine.Command` a default implementation of this function is placed in the module which performs no modifications of the processing pipeline. It is called when a command is being processed and allows for the arbitrary modification of Pipeline steps, expecting one or more Middleware callback modules in response.

  So for example if your Command Pipeline had the four callback functions as provided in the above example you could do something like:

  ```
  def middleware(Middleware.ExecuteCommand = middleware, _command_execution_object) do
    [
      Middleware.ThrottleCommand,
      middleware
    ]
  end
  ```

  The above two middlewares would then be run one-after-the-other without triggering another call to the `middleware/2` callback to avoid an infinite loop of insertions.

  ### Pipeline override at execution time

  In the same way that the entire command processing pipeline can be replaced by changing the config, a per-command override can be provided at the time of execution. Overriding the processing pipeline in this way will only impact the single command being processed while the rest will continue to use the default pipeline provided in the config.
  """

  @doc """
  The middleware callback function operates on an '%Exmud.Engine.Command.Execution{}' struct, returning an updated version for further processing by additional middlewares.
  """
  @callback execute(Exmud.Engine.Command.Execution.t()) :: {:ok, Exmud.Engine.Command.Execution.t()} | {:error, reason :: term}
end
