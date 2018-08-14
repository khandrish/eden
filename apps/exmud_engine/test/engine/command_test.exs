defmodule Exmud.Engine.Test.CommandTest do
  alias Exmud.Engine.Command
  alias Exmud.Engine.CommandSet
  alias Exmud.Engine.Object
  alias Exmud.Engine.Repo
  require Logger
  use Exmud.Engine.Test.DBTestCase

  alias Exmud.Engine.Test.CommandSet.Basic

  describe "command" do
    setup [ :create_new_object ]

    @tag command: true
    test "with building a command list when CommandSet has been unregistered", %{ object_id: object_id } = _context do
      assert CommandSet.attach( object_id, Basic ) == :ok
      executionContext = Command.execute( object_id, "echo foobar" )
      assert executionContext.args == "foobar"
      assert executionContext.matched_key == "echo"
    end
  end

  defp create_new_object(_context) do
    object_id = Object.new!()

    %{object_id: object_id}
  end
end
