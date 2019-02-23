defmodule Exmud.Engine.Test.Middleware.Error do
  @moduledoc """
  Returns an error upon execution.
  """

  use Exmud.Engine.Command
  alias Exmud.Engine.Command.ExecutionContext

  @impl true
  def key(_context), do: "echo"

  @impl true
  @spec execute(%ExecutionContext{}) ::
          {:ok, %ExecutionContext{}} | {:error, atom(), %ExecutionContext{}}
  def execute(context) do
    {:error, :bad, context}
  end
end
