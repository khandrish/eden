defmodule Exmud.Engine.Test.Component.Bad do
  @behaviour Exmud.Engine.Component

  @doc false
  @impl true
  def init(_args), do: %{}

  def populate(_object_id, _args) do
    {:error, :fubar}
  end
end
