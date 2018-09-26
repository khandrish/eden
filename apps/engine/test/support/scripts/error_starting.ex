defmodule Exmud.Engine.Test.Script.ErrorStarting do
  use Exmud.Engine.Script

  def start(_, error, _), do: {:error, error, nil}
end
