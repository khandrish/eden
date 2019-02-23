defmodule Exmud.Engine.Test.Middleware.Error do
  @moduledoc """
  Returns an error upon execution.
  """
  use Exmud.Engine.Command

  @impl true
  def key(_context), do: "echo"

  @impl true
  def execute(context) do
    {:error, :bad, context}
  end
end
