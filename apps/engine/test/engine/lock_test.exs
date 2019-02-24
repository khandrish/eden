defmodule Exmud.Engine.Test.LockTest do
  alias Exmud.Engine.Lock
  alias Exmud.Engine.Object
  require Logger
  use Exmud.Engine.Test.DBTestCase

  # Test Locks
  alias Exmud.Engine.Test.Lock.Basic

  describe "locks and manipulation on Objects" do
    setup [:create_new_objects]

    @tag lock: true
    test "when an attach/detach lifecycle", %{object_id1: object_id1} = _context do
      assert Lock.locked?(object_id1, "foo") == false
      assert Lock.lock(object_id1, "foo", Basic) == :ok
      assert Lock.lock(object_id1, "foo", Basic) == {:error, :already_attached}
      assert Lock.locked?(object_id1, "foo") == true
      assert Lock.unlock(object_id1, "foo") == :ok
      assert Lock.locked?(object_id1, "foo") == false
    end

    @tag lock: true
    test "check a lock", %{object_id1: object_id1, object_id2: object_id2} = _context do
      assert Lock.lock(object_id1, "foo", Basic) == :ok
      assert Lock.locked?(object_id1, "foo") == true
      assert Lock.check(object_id1, "foo", object_id2) == {:ok, false}
      assert Lock.check!(object_id1, "foo", object_id2) == false
    end

    @tag lock: true
    test "when check! input is bad" do
      assert_raise ArgumentError, "no such lock", fn ->
        Lock.check!(0, "foo", 0)
      end
    end

    @tag lock: true
    test "when attaching to nonexisting Object" do
      assert Lock.lock(0, "foo", Basic) == {:error, :no_such_object}
    end
  end

  defp create_new_objects(context) do
    object_id1 = Object.new!()
    object_id2 = Object.new!()

    context
    |> Map.put(:object_id1, object_id1)
    |> Map.put(:object_id2, object_id2)
  end
end
