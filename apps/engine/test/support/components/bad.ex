defmodule Exmud.Engine.Test.Component.Bad do
  use Exmud.Engine.Component

  def populate(_object_id, _args) do
    {:error, :fubar}
  end
end
