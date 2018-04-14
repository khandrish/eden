defmodule Exmud.Engine.Test.Script.ErrorStopping do
  use Exmud.Engine.Script

  def stop(_, error, state), do: {:error, error, state}
end