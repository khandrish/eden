defmodule Exmud.Engine.Test.ScriptTest do
  alias Ecto.UUID
  alias Exmud.Engine.Script
  alias Exmud.Engine.Object
  alias Exmud.Engine.Repo
  require Logger
  use Exmud.Engine.Test.DBTestCase

  describe "Tests for scripts:" do
    setup [:create_new_object]

    # @tag script: true
    # @tag engine: true
    # test "lifecycle", %{object_id: object_id} = _context do
    #   callback_module = UUID.generate()
    #   assert Script.add(object_id, callback_module) == {:ok, object_id}
    #   assert Script.has(object_id, callback_module) == {:ok, true}
    #   assert Script.has_any(object_id, ["foo"]) == {:ok, false}
    #   assert Script.has_any(object_id, [callback_module, "foo"]) == {:ok, true}
    #   assert Script.remove(object_id, callback_module) == {:ok, true}
    #   assert Script.has(object_id, callback_module) == {:ok, false}
    # end

    @tag script: true
    @tag engine: true
    test "engine registration" do
      key = UUID.generate()
      callback_module = UUID.generate()
      assert Script.register(key, callback_module) == {:ok, true}
      assert Script.registered?(key) == {:ok, true}
      assert Enum.any?(Script.list_registered(), fn(k) -> key == k end) == true
      assert Script.lookup(callback_module) == {:error, :no_such_script}
      {:ok, callback} = Script.lookup(key)
      assert callback == callback_module
      assert Script.unregister(key) == {:ok, true}
      assert Script.registered?(key) == {:ok, false}
      assert Enum.any?(Script.list_registered(), fn(k) -> key == k end) == false
    end

    # @tag script: true
    # @tag engine: true
    # test "invalid input" do
    #   callback_module = UUID.generate()
    #   assert Script.add(0, callback_module) == {:error, :no_such_object}
    #   assert Script.has(0, callback_module) == {:ok, false}
    #   assert Script.remove(0, callback_module) == {:error, :no_such_script}
    # end
  end

  defp create_new_object(_context) do
    key = UUID.generate()
    {:ok, object_id} = Object.new(key)

    %{key: key, object_id: object_id}
  end
end