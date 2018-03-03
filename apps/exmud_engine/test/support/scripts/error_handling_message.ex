defmodule Exmud.Engine.Test.Script.ErrorHandlingMessage do
  use Exmud.Engine.Script

  def handle_message(_object_id, _message, state), do: {:error, "error", state}
end