defmodule Exmud.Engine.Command.Middleware do
  @moduledoc """
  Middleware is responsible for every stage of processing a Command.

  By specifying `@behaviour Exmud.Engine.Command.Middleware` the compiler will ensure that a `def execute` callback has been provided. The function takes an `%Exmud.Engine.Command.Execution{}` struct as the only argument and expects an updated struct or an error tuple in return.

  See 'Exmud.Engine.Command.Execution' for further details.

  Middleware can be configured for use in a couple of ways:

  1. Override the default command processing pipeline configuration.
  2. Provide an override pipeline on execution of a Command.

  ## Configuration

  Overriding the pipeline via config changes how every command is processed. Check the existing config before overriding to ensure critical steps in the pipeline are not missed.

  Note: The override should be done in the Game application and not the Engine application. Unless contributing there should be no need to modify anything in the Engine.

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

  ### Pipeline override at execution time

  In the same way that the entire command processing pipeline can be replaced by changing the config, a per-command override can be provided at the time of execution. Overriding the processing pipeline in this way will only impact the single command being processed while the rest will continue to use the default pipeline provided in the config.
  """

  @doc """
  The middleware callback function operates on an '%Exmud.Engine.Command.Execution{}' struct, returning an updated version for further processing by additional middlewares.
  """
  @callback execute(Exmud.Engine.Command.ExecutionContext.t()) ::
              {:ok, Exmud.Engine.Command.ExecutionContext.t()} | {:error, reason :: term}
end
