defmodule Exmud.Engine.Test.LockTest do
  alias Exmud.Engine.Lock
  alias Exmud.Engine.Object
  require Logger
  use Exmud.Engine.Test.DBTestCase

  # Test Locks
  alias Exmud.Engine.Test.Lock.Basic
  alias Exmud.Engine.Test.Lock.NotRegistered

  describe "Engine registration:" do

    @tag lock: true
    @tag engine: true
    test "registration lifecycle" do
      assert Lock.lookup(NotRegistered.name()) == {:error, :no_such_lock}
      assert Enum.member?(Lock.list_registered(), NotRegistered.name()) == false
      assert Lock.registered?(NotRegistered) == false
      assert Lock.register(NotRegistered) == :ok
      assert Enum.member?(Lock.list_registered(), NotRegistered.name()) == true
      assert Lock.lookup(NotRegistered.name()) == {:ok, NotRegistered}
      assert Lock.unregister(NotRegistered) == :ok
      assert Enum.member?(Lock.list_registered(), NotRegistered.name()) == false
      assert Lock.registered?(NotRegistered) == false
    end
  end

  describe "Obect manipulation:" do
    setup [:create_new_objects, :register_test_locks]

    @tag lock: true
    @tag engine: true
    test "attach/detach lifecycle", %{object_id1: object_id1} = _context do
      assert Lock.attached?(object_id1, "foo") == false
      assert Lock.attach(object_id1, "foo", Basic.name()) == :ok
      assert Lock.attached?(object_id1, "foo") == true
      assert Lock.detach(object_id1, "foo") == :ok
      assert Lock.attached?(object_id1, "foo") == false
    end

    @tag lock: true
    @tag engine: true
    test "check a lock", %{object_id1: object_id1, object_id2: object_id2} = _context do
      assert Lock.attach(object_id1, "foo", NotRegistered.name()) == :ok
      assert Lock.check(object_id1, "foo", object_id2) == {:error, :no_such_lock}
    end

    @tag lock: true
    @tag engine: true
    test "check a lock which isn't registered", %{object_id1: object_id1, object_id2: object_id2} = _context do
      assert Lock.attach(object_id1, "foo", Basic.name()) == :ok
      assert Lock.attached?(object_id1, "foo") == true
      assert Lock.check(object_id1, "foo", object_id2) == {:ok, false}
      assert Lock.check!(object_id1, "foo", object_id2) == false
    end
  end

  defp create_new_objects(context) do
    object_id1 = Object.new!()
    object_id2 = Object.new!()

    context
    |> Map.put(:object_id1, object_id1)
    |> Map.put(:object_id2, object_id2)
  end

  @locks [Basic]

  defp register_test_locks(context) do
    Enum.each(@locks, &Lock.register/1)

    context
  end
end