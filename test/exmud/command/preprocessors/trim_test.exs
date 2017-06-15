defmodule Exmud.Command.Transformer.TrimTest do
  alias Exmud.Command.Transformer.Trim
  require Logger
  use ExUnit.Case

  describe "trim " do

    @tag command_transformer: true
    test "trim" do
      assert Trim.transform(" foobar ") == "foobar"
    end
  end
end
