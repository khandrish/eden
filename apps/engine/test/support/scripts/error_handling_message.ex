defmodule Exmud.Engine.Test.Script.ErrorHandlingMessage do
  @moduledoc false
  use Exmud.Engine.Script

  @spec handle_message(integer(), any(), any()) :: {:ok, any(), any()} | {:error, atom(), any()}
  def handle_message(_object_id, message, state), do: {:error, message, state}
end
