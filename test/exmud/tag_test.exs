defmodule Exmud.TagTest do
  alias Ecto.UUID
  alias Exmud.Tag
  alias Exmud.GameObject
  require Logger
  use ExUnit.Case, async: true

  describe "tag tests: " do
    setup [:create_new_game_object]

    @tag tag: true
    test "lifecycle", %{oid: oid} = _context do
      assert Tag.has?(oid, "foo") == {:ok, false}
      assert Tag.has?(oid, "foo", "bar") == {:ok, false}
      assert Tag.add(oid, "foo") == :ok
      assert Tag.add(oid, "foo", "bar") == :ok
      assert Tag.has?(oid, "foo") == {:ok, true}
      assert Tag.has?(oid, "foo", "bar") == {:ok, true}
      assert Tag.remove(oid, "foo") == :ok
      assert Tag.has?(oid, "foo") == {:ok, false}
      assert Tag.has?(oid, "foo", "bar") == {:ok, true}
    end
    
    @tag tag: true
    test "invalid cases" do
      assert Tag.add("invalid id", :invalid_tag, "bar") ==
        {:error,
          [oid: {"is invalid", [type: :id, validation: :cast]},
           key: {"is invalid", [type: :string, validation: :cast]}]}
      assert Tag.has?(0, "foo") == {:ok, false}
      assert Tag.remove(0, "foo") == {:error, :no_such_tag}
    end
  end

  defp create_new_game_object(_context) do
    key = UUID.generate()
    {:ok, oid} = GameObject.new(key)
    %{key: key, oid: oid}
  end
end
