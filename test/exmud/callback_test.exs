defmodule Exmud.CallbackTest do
  alias Exmud.Callback
  alias Exmud.CallbackTest.ExampleCallback, as: EC
  alias Exmud.GameObject
  require Logger
  use ExUnit.Case, async: true

  describe "callback tests: " do
    setup [:create_new_game_object]
    
    test "engine registration", %{oid: oid} = _context do
      assert Callback.registered?("foo") == false
      assert Callback.register("foo", EC) == :ok
      assert Callback.registered?("foo") == true
      assert Callback.which_module("foo") == {:ok, EC}
      assert Callback.unregister("foo") == :ok
      assert Callback.registered?("foo") == false
    end

    test "lifecycle", %{oid: oid} = _context do
      assert Callback.register("foo", EC) == :ok
      assert Callback.has?(oid, "foo") == {:ok, false}
      assert Callback.add(oid, "foo", "foo") == :ok
      assert Callback.has?(oid, "foo") == {:ok, true}
      assert Callback.get(oid, "foo", IO) == {:ok, EC}
      assert Callback.delete(oid, "foo") == :ok
      assert Callback.has?(oid, "foo") == {:ok, false}
    end

    test "invalid cases", %{oid: oid} = _context do
      assert Callback.has?(0, "foo") == {:error, :no_such_game_object}
      assert Callback.add(0, "foo", "foo") == {:error, :no_such_game_object}
      assert Callback.get(0, "foo", IO) == {:error, :no_such_game_object}
      assert Callback.delete(0, "foo") == {:error, :no_such_callback}
      assert Callback.get(oid, "foo", IO) == {:ok, IO}
    end
  end

  defp create_new_game_object(_context) do
    key = UUID.uuid4()
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