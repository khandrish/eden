defmodule Exmud.Engine.Test.CommandSetTest do
  alias Ecto.UUID
  alias Exmud.Engine.CommandSet
  alias Exmud.Engine.Object
  alias Exmud.Engine.Repo
  require Logger
  use Exmud.Engine.Test.DBTestCase

  alias Exmud.Engine.Test.CommandSet.Basic

  describe "command set" do
    setup [:create_new_object, :register_test_command_set]

    @tag command_set: true
    @tag engine: true
    test "with successful attach", %{object_id: object_id} = _context do
      assert CommandSet.attach(object_id, Basic.name()) == :ok
      assert CommandSet.attach(object_id, Basic.name()) == {:error, :already_attached}
    end

    @tag command_set: true
    @tag engine: true
    test "with successful detach!", %{object_id: object_id} = _context do
      assert CommandSet.attach(object_id, Basic.name()) == :ok
      assert CommandSet.detach!(object_id, Basic.name()) == :ok
    end

    @tag command_set: true
    @tag engine: true
    test "with has_* checks", %{object_id: object_id} = _context do
      assert CommandSet.has_all?(object_id, Basic.name()) == false
      assert CommandSet.has_any?(object_id, [Basic.name()]) == false
      assert CommandSet.attach(object_id, Basic.name()) == :ok
      assert CommandSet.has_all?(object_id, Basic.name()) == true
      assert CommandSet.has_any?(object_id, ["foo"]) == false
      assert CommandSet.has_any?(object_id, [Basic.name(), "foo"]) == true
      assert CommandSet.detach(object_id, Basic.name()) == :ok
      assert CommandSet.has_any?(object_id, Basic.name()) == false
    end

    @tag command_set: true
    @tag engine: true
    test "engine registration" do
      assert CommandSet.register(Basic) == :ok
      assert CommandSet.registered?(Basic) == true
      assert Enum.any?(CommandSet.list_registered(), fn(k) -> Basic.name() == k end) == true
      assert CommandSet.lookup("foo") == {:error, :no_such_command_set}
      {:ok, callback} = CommandSet.lookup(Basic.name())
      assert callback == Basic
      assert CommandSet.unregister(Basic) == :ok
      assert CommandSet.registered?(Basic) == false
      assert Enum.any?(CommandSet.list_registered(), fn(k) -> Basic.name == k end) == false
    end

    @tag command_set: true
    @tag engine: true
    test "invalid input" do
      assert CommandSet.attach(0, Basic.name()) == {:error, :no_such_object}
      assert CommandSet.attach(0, "foo") == {:error, :no_such_command_set}
      assert CommandSet.has_any?(0, Basic.name()) == false
      assert CommandSet.has_all?(0, Basic.name()) == false
      assert CommandSet.detach(0, Basic.name()) == :error
    end
  end

  defp create_new_object(_context) do
    object_id = Object.new!()

    %{object_id: object_id}
  end

  @command_sets [Basic]

  defp register_test_command_set(context) do
    Enum.each(@command_sets, &CommandSet.register/1)

    context
  end
end