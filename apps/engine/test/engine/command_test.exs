defmodule Exmud.Engine.Test.CommandTest do
  @moduledoc false
  alias Exmud.Engine.Command
  require Logger
  use ExUnit.Case, async: true

  describe "command" do
    test "with successful execution" do
      {:ok, context} = Command.execute(1, "echo foobar", [Exmud.Engine.Test.Middleware.Echo])

      assert Exmud.Engine.Command.ExecutionContext.get(context, :echo) == "foobar"
    end

    test "with error" do
      {:error, error, pipeline_step, _context} =
        Command.execute(1, "blah", [Exmud.Engine.Test.Middleware.Error])

      assert error == :bad
      assert pipeline_step == Exmud.Engine.Test.Middleware.Error
    end
  end
end
