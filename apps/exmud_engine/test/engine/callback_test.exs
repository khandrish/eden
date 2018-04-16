defmodule Exmud.Engine.Test.CallbackTest do
  alias Exmud.Engine.Callback
  alias Exmud.Engine.Object
  require Logger
  use Exmud.Engine.Test.DBTestCase, async: false

  # Test Callbacks
  alias Exmud.Engine.Test.Callback.Basic
  alias Exmud.Engine.Test.Callback.NotRegistered

  describe "callbacks" do
    setup [:create_new_object, :register_test_callbacks]

    @tag callback: true
    @tag engine: true
    test "with engine registration" do
      assert Callback.registered?(NotRegistered) == false
      assert Callback.lookup("foo") == {:error, :no_such_callback}
      assert Callback.registered?(Basic) == true
      assert Callback.lookup(Basic.name()) == {:ok, Basic}
      assert Enum.any?(Callback.list_registered(), fn(key) -> key == Basic.name() end) == true
      assert Callback.unregister(Basic) == :ok
      assert Callback.registered?(Basic) == false
      assert Enum.any?(Callback.list_registered(), fn(key) -> key == Basic.name() end) == false
    end

    @tag callback: true
    @tag engine: true
    test "lifecycle", %{object_id: object_id} = _context do
      assert Callback.run(object_id, Basic.key(), :ok, %{}) == {:error, :no_such_callback}
      assert Callback.is_attached?(object_id, Basic.name()) == false
      assert Callback.run(object_id, Basic.key(), :ok, %{}, Basic.name()) == :ok
      assert Callback.attach(object_id, Basic.name()) == :ok
      assert Callback.run(object_id, Basic.key(), :ok, %{}) == :ok
      assert Callback.detach(object_id, Basic.key()) == :ok
      assert Callback.is_attached?(object_id, Basic.name()) == false
    end

    @tag callback: true
    @tag engine: true
    test "with invalid cases" do
      assert Callback.is_attached?(0, "foo") == false
      assert Callback.attach(0, Basic.name()) == {:error, :no_such_object}
      assert Callback.get(0, "foo") == {:error, :no_such_callback}
      assert Callback.detach(0, "foo") == {:error, :no_such_callback}
    end

    @tag callback: true
    @tag engine: true
    test "by attaching with invalid callback", %{object_id: object_id} = _context do
      assert Callback.attach(object_id, "foo") == {:error, :no_such_callback}
    end
  end

  defp create_new_object(_context) do
    object_id = Object.new!()

    %{object_id: object_id}
  end

  @callbacks [Basic]

  defp register_test_callbacks(context) do
    Enum.each(@callbacks, &Callback.register/1)

    context
  end
end
