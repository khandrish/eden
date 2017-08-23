defmodule Exmud.Engine.Test.CallbackTest do
  alias Ecto.UUID
  alias Exmud.Engine.Callback
  alias Exmud.Engine.Test.CallbackTest.ExampleCallback, as: EC
  alias Exmud.Engine.Object
  require Logger
  use Exmud.Engine.Test.DBTestCase, async: false

  describe "global callback tests: " do

    @tag callback: true
    @tag engine: true
    test "engine registration" do
      callback = UUID.generate()
      assert Callback.registered?(callback) == {:ok, false}
      assert Callback.lookup(callback) == {:error, :no_such_callback}
      assert Callback.register(callback, EC) == {:ok, true}
      assert Callback.registered?(callback) == {:ok, true}
      assert Callback.lookup(callback) == {:ok, EC}
      assert Enum.any?(Callback.list_registered(), fn(key) -> key == callback end) == true
      assert Callback.unregister(callback) == {:ok, true}
      assert Callback.registered?(callback) == {:ok, false}
      assert Enum.any?(Callback.list_registered(), fn(key) -> key == callback end) == false
    end
  end

  describe "callback multi tests: " do
    setup [:create_new_object]

    @tag callback: true
    @tag engine: true
    test "callback lifecycle", %{object_id: object_id} = _context do
      fun = fn(_, _) -> {:ok, :ok} end
      callback = UUID.generate()
      assert Callback.register(callback, fun) == {:ok, true}
      assert Callback.run(object_id, callback, :ok) == {:ok, :ok}
      assert Callback.has(object_id, "foo") == {:ok, false}
      assert Callback.add(object_id, "foo", fun) == {:ok, object_id}
      assert Callback.add(object_id, "foobar", fun) == {:ok, object_id}
      assert Callback.has(object_id, "foo") == {:ok, true}
      assert Callback.get(object_id, "foo") == {:ok, fun}
      assert Callback.get(object_id, "fooo", fun) == {:ok, fun}
      assert Callback.remove(object_id, "foo") == {:ok, object_id}
      assert Callback.has(object_id, "foo") == {:ok, false}
      assert Callback.run(object_id, "foobar", []) == {:ok, :ok}
    end

    @tag callback: true
    @tag engine: true
    test "callback invalid cases" do
      assert Callback.has(0, "foo") == {:ok, false}
      assert Callback.add(0, "foo", "foo") == {:error, :no_such_object}
      assert Callback.get(0, "foo") == {:error, :no_such_callback}
      assert Callback.remove(0, "foo") == {:error, :no_such_callback}
    end
  end

  defp create_new_object(_context) do
    key = UUID.generate()
    {:ok, object_id} = Object.new(key)
    %{key: key, object_id: object_id}
  end
end

defmodule Exmud.Engine.Test.CallbackTest.ExampleCallback do
  @moduledoc """
  A barebones example of a callback for testing.
  """

  def run(_object_id, _args) do
    {:ok, :ok}
  end
end




