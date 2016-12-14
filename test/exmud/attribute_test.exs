defmodule Exmud.AttributeTest do
  alias Exmud.Attribute
  alias Exmud.GameObject
  require Logger
  use ExUnit.Case, async: true

  describe "attribute tests: " do
    setup [:create_new_game_object]

    test "lifecycle", %{oid: oid} = _context do
      assert Attribute.add(oid, "foo", "bar") == :ok
      assert Attribute.get(oid, "foo") == {:ok, "bar"}
      assert Attribute.has?(oid, "foo") == {:ok, true}
      assert Attribute.remove(oid, "foo") == :ok
      assert Attribute.get(oid, "foo") == {:error, :no_such_attribute}
      assert Attribute.has?(oid, "foo") == {:ok, false}
    end

    test "invalid cases", %{oid: oid} = _context do
      assert Attribute.get(oid, "foo") == {:error, :no_such_attribute}
      assert Attribute.add("invalid id", :invalid_name, "bar") ==
        {:error,
          [name: {"is invalid", [type: :string]},
           oid: {"is invalid", [type: :id]}]}
      assert Attribute.add(0, "foo", "bar") == {:error, [oid: {"does not exist", []}]}
      assert Attribute.has?(0, "foo") == {:error, :no_such_game_object}
      assert Attribute.remove(0, "foo") == {:error, :no_such_attribute}
      assert Attribute.get(0, "foo") == {:error, :no_such_game_object}
    end
  end

  defp create_new_game_object(_context) do
    key = UUID.uuid4()
    {:ok, oid} = GameObject.new(key)
    %{key: key, oid: oid}
  end
end
