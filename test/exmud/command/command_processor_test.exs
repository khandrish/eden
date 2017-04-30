defmodule Exmud.CommandProcessorTest do
  alias Ecto.UUID
  alias Exmud.CommandProcessor
  require Logger
  use ExUnit.Case

  describe "command processor tests: " do
    @tag command_processor: true
    test "command processor lifecycle" do
      command_string = "move north"
      {:ok, ref} = CommandProcessor.process(command_string, UUID.generate())
      assert rec(ref) == :ok
    end
  end

  defp rec(ref) do
    receive do
      {:command_processing_done, ref, :ok} -> :ok
      after 1000 -> :error
    end
  end
end
