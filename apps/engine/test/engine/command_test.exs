defmodule Exmud.Engine.Test.CommandTest do
  @moduledoc false
  alias Exmud.Engine.Command
  alias Exmud.Engine.Repo
  require Logger
  use ExUnit.Case, async: true

  alias Exmud.Engine.Test.CommandSet.Basic

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
