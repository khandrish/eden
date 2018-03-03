defmodule Exmud.Engine.Test.Script.ErrorInitializing do
  use Exmud.Engine.Script

  def initialize(_, _), do: {:error, "error"}
end