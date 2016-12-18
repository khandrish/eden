defmodule Exmud.CallbackTest do
  alias Ecto.UUID
  alias Exmud.Callback
  alias Exmud.CallbackTest.ExampleCallback, as: EC
  alias Exmud.GameObject
  require Logger
  use ExUnit.Case

  describe "callback tests: " do
    setup [:create_new_game_object]
    
    @tag callback: true
    test "engine registration" do
      callback = UUID.generate()
      assert Callback.registered?(callback) == false
      assert Callback.register(callback, EC) == :ok
      assert Callback.registered?(callback) == true
      assert Callback.which_module(callback) == {:ok, EC}
      assert Callback.unregister(callback) == :ok
      assert Callback.registered?(callback) == false
    end
    
    @tag callbacs: true
    test "lifecycle", %{oid: oid} = _context do
      assert Callback.register("foo", EC) == :ok
      assert Callback.has?(oid, "foo") == {:ok, false}
      assert Callback.add(oid, "foo", "foo") == :ok
      assert Callback.add(oid, "foobar", "foo") == :ok
      assert Callback.list("foo") == [oid]
      assert Callback.list(["foo", "foobar"]) == [oid]
      assert Callback.has?(oid, "foo") == {:ok, true}
      assert Callback.get(oid, "foo", "foobar") == {:ok, EC}
      assert Callback.delete(oid, "foo") == :ok
      assert Callback.has?(oid, "foo") == {:ok, false}
    end
    
    @tag callback: true
    test "invalid cases", %{oid: oid} = _context do
      assert Callback.has?(0, "foo") == {:ok, false}
      assert Callback.add(0, "foo", "foo") == {:error, :no_such_game_object}
      assert Callback.get(0, "foo", "foobar") == {:error, :no_such_callback}
      assert Callback.delete(0, "foo") == {:error, :no_such_callback}
      assert Callback.register("foobar", IO) == :ok
      assert Callback.get(oid, "foo", "foobar") == {:ok, IO}
    end
  end

  defp create_new_game_object(_context) do
    key = UUID.generate()
    {:ok, oid} = GameObject.new(key)
    %{key: key, oid: oid}
  end
end

defmodule Exmud.CallbackTest.ExampleCallback do
  @moduledoc """
  A barebones example of a callback for testing.
  """
  
  def run(_oid) do
    :ok
  end
end