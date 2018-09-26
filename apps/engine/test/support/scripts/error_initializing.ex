defmodule Exmud.Engine.Test.Script.ErrorInitializing do
  use Exmud.Engine.Script

  def initialize(_object_id, error), do: {:error, error}
end
