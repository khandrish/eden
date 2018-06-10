defmodule Exmud.Engine.Command.Middleware.FilterSystemCommands do
  @moduledoc """
  This middleware prevents system commands from being sent as input. Any system commands are mapped to a no match error.
  """

  @behaviour Exmud.Engine.Command.Middleware

  alias Exmud.Engine.CommandSet

  def execute(execution) do
    if String.starts_with?(execution.raw_input, "CMD_") do
      {:ok, %{execution | raw_input: "CMD_NO_MATCH"}}
    else
      {:ok, execution}
    end
  end
end
