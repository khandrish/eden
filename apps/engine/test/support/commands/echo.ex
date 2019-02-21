defmodule Exmud.Engine.Test.Command.Echo do
  @moduledoc """
  Echoes the text following the 'echo' command back to the player.
  """
  use Exmud.Engine.Command

  @impl true
  def key(_context), do: "echo"

  @impl true
  def execute(context) do
    {:ok, %{context | events: [{:message, context.caller, context.args}]}}
  end
end
