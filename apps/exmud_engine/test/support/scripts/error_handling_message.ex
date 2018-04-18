defmodule Exmud.Engine.Test.Script.ErrorHandlingMessage do
  use Exmud.Engine.Script

  def handle_message(_object_id, message, state), do: {:error, message, state}
end
