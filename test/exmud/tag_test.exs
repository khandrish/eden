defmodule Exmud.TagTest do
  alias Exmud.Tag
  alias Exmud.GameObject
  require Logger
  use ExUnit.Case, async: true

  describe "tag tests: " do
    setup [:create_new_game_object]

    @tag wip: true
    test "tag tests", %{oid: oid} = _context do
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
  end

  defp create_new_game_object(_context) do
    key = UUID.uuid4()
    {:ok, oid} = GameObject.new(key)
    %{key: key, oid: oid}
  end
end
