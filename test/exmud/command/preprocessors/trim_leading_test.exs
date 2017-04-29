defmodule Exmud.Command.Preproccessor.TrimLeadingTest do
  alias Exmud.Command.Preproccessor.TrimLeading
  require Logger
  use ExUnit.Case

  describe "trim leading " do

    @tag command_preprocessor: true
    test "trim" do
      assert TrimLeading.run(" foobar") == "foobar"
    end
  end
end
