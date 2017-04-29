defmodule Exmud.Command.Preproccessor.TrimTrailingTest do
  alias Exmud.Command.Preproccessor.TrimTrailing
  require Logger
  use ExUnit.Case

  describe "trim trailing " do

    @tag command_preprocessor: true
    test "trim" do
      assert TrimTrailing.run("foobar ") == "foobar"
    end
  end
end
