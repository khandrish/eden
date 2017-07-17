defmodule Exmud.Engine.Test.CommandSetTest do
  alias Ecto.UUID
  alias Exmud.Engine.CommandSet
  alias Exmud.Engine.Object
  alias Exmud.Engine.Repo
  require Logger
  use Exmud.Engine.Test.DBTestCase

  describe "Tests for command sets:" do
    setup [:create_new_object]

    @tag command_set: true
    @tag engine: true
    test "lifecycle", %{object_id: object_id} = _context do
      callback_module = UUID.generate()
      assert CommandSet.add(object_id, callback_module) == {:ok, object_id}
      assert CommandSet.has(object_id, callback_module) == {:ok, true}
      assert CommandSet.has_any(object_id, ["foo"]) == {:ok, false}
      assert CommandSet.has_any(object_id, [callback_module, "foo"]) == {:ok, true}
      assert CommandSet.remove(object_id, callback_module) == {:ok, true}
      assert CommandSet.has(object_id, callback_module) == {:ok, false}
    end

    @tag command_set: true
    @tag engine: true
    test "invalid input" do
      callback_module = UUID.generate()
      assert CommandSet.add(0, callback_module) == {:error, :no_such_object}
      assert CommandSet.has(0, callback_module) == {:ok, false}
      assert CommandSet.remove(0, callback_module) == {:error, :no_such_command_set}
    end
  end

  defp create_new_object(_context) do
    key = UUID.generate()
    {:ok, object_id} = Object.new(key)

    %{key: key, object_id: object_id}
  end
end