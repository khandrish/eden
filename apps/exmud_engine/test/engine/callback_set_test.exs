defmodule Exmud.Engine.Test.CallbackSetTest do
  alias Exmud.Engine.CallbackSet
  alias Exmud.Engine.Object
  alias Exmud.Engine.Repo
  require Logger
  use Exmud.Engine.Test.DBTestCase

  alias Exmud.Engine.Test.CallbackSet.Basic
  alias Exmud.Engine.Test.CallbackSet.HighPriority
  alias Exmud.Engine.Test.CallbackSet.Replace

  describe "callback set" do
    setup [:create_new_object, :register_test_callback_set]

    @tag callback_set: true
    test "with successful attach", %{object_id: object_id} = _context do
      assert CallbackSet.attach(object_id, Basic.name()) == :ok
      assert CallbackSet.attach(object_id, Basic.name()) == {:error, :already_attached}
    end

    @tag callback_set: true
    test "with successful detach!", %{object_id: object_id} = _context do
      assert CallbackSet.attach(object_id, Basic.name()) == :ok
      assert CallbackSet.detach!(object_id, Basic.name()) == :ok
    end

    @tag callback_set: true
    test "with has_* checks", %{object_id: object_id} = _context do
      assert CallbackSet.has_all?(object_id, Basic.name()) == false
      assert CallbackSet.has_any?(object_id, [Basic.name()]) == false
      assert CallbackSet.attach(object_id, Basic.name()) == :ok
      assert CallbackSet.has_all?(object_id, Basic.name()) == true
      assert CallbackSet.has_any?(object_id, ["foo"]) == false
      assert CallbackSet.has_any?(object_id, [Basic.name(), "foo"]) == true
      assert CallbackSet.detach(object_id, Basic.name()) == :ok
      assert CallbackSet.has_any?(object_id, Basic.name()) == false
    end

    @tag callback_set: true
    test "engine registration" do
      assert CallbackSet.register(Basic) == :ok
      assert CallbackSet.registered?(Basic) == true
      assert Enum.any?(CallbackSet.list_registered(), fn k -> Basic.name() == k end) == true
      assert CallbackSet.lookup("foo") == {:error, :no_such_callback_set}
      {:ok, callback} = CallbackSet.lookup(Basic.name())
      assert callback == Basic
      assert CallbackSet.unregister(Basic) == :ok
      assert CallbackSet.registered?(Basic) == false
      assert Enum.any?(CallbackSet.list_registered(), fn k -> Basic.name() == k end) == false
    end

    @tag callback_set: true
    test "invalid input" do
      assert CallbackSet.attach(0, Basic.name()) == {:error, :no_such_object}
      assert CallbackSet.attach(0, "foo") == {:error, :no_such_callback_set}
      assert CallbackSet.has_any?(0, Basic.name()) == false
      assert CallbackSet.has_all?(0, Basic.name()) == false
      assert CallbackSet.detach(0, Basic.name()) == :error
    end

    @tag callback_set: true
    test "with merging", %{object_id: object_id} = _context do
      assert CallbackSet.build_active_callback_list(0) == []
      assert CallbackSet.attach(object_id, Basic.name()) == :ok
      assert CallbackSet.build_active_callback_list(object_id) == ["foo"]
      assert CallbackSet.attach(object_id, HighPriority.name()) == :ok
      assert CallbackSet.build_active_callback_list(object_id) == ["foo", "foobar"]
    end

    @tag callback_set: true
    test "with checking the order of merging", %{object_id: object_id} = _context do
      assert CallbackSet.build_active_callback_list(0) == []
      assert CallbackSet.attach(object_id, Basic.name()) == :ok
      assert CallbackSet.build_active_callback_list(object_id) == ["foo"]
      assert CallbackSet.attach(object_id, Replace.name()) == :ok
      assert CallbackSet.build_active_callback_list(object_id) == ["farboo"]
    end

    @tag callback_set: true
    test "with checking the reverse order of merging", %{object_id: object_id} = _context do
      assert CallbackSet.build_active_callback_list(object_id) == []
      assert CallbackSet.attach(object_id, Replace.name()) == :ok
      assert CallbackSet.build_active_callback_list(object_id) == ["farboo"]
      assert CallbackSet.attach(object_id, Basic.name()) == :ok
      assert CallbackSet.build_active_callback_list(object_id) == ["foo", "farboo"]
    end

    @tag command_set: true
    test "with building a command list when CallbackSet has been unregistered", %{object_id: object_id} = _context do
      assert CallbackSet.attach(object_id, Replace.name()) == :ok
      assert CallbackSet.unregister(Replace) == :ok
      assert CallbackSet.build_active_callback_list(object_id) == []
    end
  end

  defp create_new_object(_context) do
    object_id = Object.new!()

    %{object_id: object_id}
  end

  @callback_sets [Basic, HighPriority, Replace]

  defp register_test_callback_set(context) do
    Enum.each(@callback_sets, &CallbackSet.register/1)

    context
  end
end
