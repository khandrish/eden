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
    test "engine registration" do
      key = UUID.generate()
      callback_module = UUID.generate()
      assert CommandSet.register(key, callback_module) == :ok
      assert CommandSet.registered?(key) == true
      assert Enum.any?(CommandSet.list_registered(), fn(k) -> key == k end) == true
      assert CommandSet.lookup(callback_module) == {:error, :no_such_command_set}
      {:ok, callback} = CommandSet.lookup(key)
      assert callback == callback_module
      assert CommandSet.unregister(key) == :ok
      assert CommandSet.registered?(key) == false
      assert Enum.any?(CommandSet.list_registered(), fn(k) -> key == k end) == false
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
    object_id = Object.new!()

    %{object_id: object_id}
  end
end