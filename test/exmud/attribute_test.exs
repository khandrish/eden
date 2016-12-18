defmodule Exmud.AttributeTest do
  alias Ecto.UUID
  alias Exmud.Attribute
  alias Exmud.GameObject
  require Logger
  use ExUnit.Case, async: true

  describe "attribute tests: " do
    setup [:create_new_game_object]

    @tag attribute: true
    test "lifecycle", %{oid: oid} = _context do
      attribute = UUID.generate()
      assert Attribute.add(oid, attribute, "bar") == :ok
      assert Attribute.get(oid, attribute) == {:ok, "bar"}
      assert Attribute.has?(oid, attribute) == {:ok, true}
      assert Attribute.list(attribute) == [oid]
      assert Attribute.remove(oid, attribute) == :ok
      assert Attribute.get(oid, attribute) == {:error, :no_such_attribute}
      assert Attribute.has?(oid, attribute) == {:ok, false}
    end

    @tag attribute: true
    test "invalid cases", %{oid: oid} = _context do
      assert Attribute.get(oid, "foo") == {:error, :no_such_attribute}
      assert Attribute.add("invalid id", :invalid_name, "bar") ==
        {:error,
          [key: {"is invalid", [type: :string, validation: :cast]},
           oid: {"is invalid", [type: :id, validation: :cast]}]}
      assert Attribute.add(0, "foo", "bar") == {:error, [oid: {"does not exist", []}]}
      assert Attribute.has?(0, "foo") == {:error, :no_such_game_object}
      assert Attribute.remove(0, "foo") == {:error, :no_such_attribute}
      assert Attribute.get(0, "foo") == {:error, :no_such_game_object}
    end
  end

  defp create_new_game_object(_context) do
    key = UUID.generate()
    {:ok, oid} = GameObject.new(key)
    %{key: key, oid: oid}
  end
end
