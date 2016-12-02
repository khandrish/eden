defmodule Exmud.GameObjectTest do
  alias Exmud.GameObject
  alias Exmud.Repo
  require Logger
  use ExUnit.Case, async: true

  describe "game object tests: " do
    setup [:create_new_game_object]

    test "delete tests", %{oid: oid} = _context do
      assert GameObject.delete(oid) == :ok
      assert GameObject.delete(0) == :ok
    end

    test "tag tests", %{oid: oid} = _context do
      assert GameObject.has_tag?(oid, "foo") == false
      assert GameObject.add_tag(oid, "foo") == :ok
      assert GameObject.has_tag?(oid, "foo") == true
      assert MapSet.member?(MapSet.new(GameObject.list(tags: "foo")), oid) == true
      assert GameObject.add_tag(oid, "bar") == :ok
      assert GameObject.has_tag?(oid, "bar") == true
      assert MapSet.member?(MapSet.new(GameObject.list(tags: ["foo", "bar"])), oid) == false
      assert GameObject.remove_tag(oid, "foo") == :ok
      assert GameObject.has_tag?(oid, "foo") == false
    end

    test "attribute tests", %{oid: oid} = _context do
      assert GameObject.has_attribute?(oid, "foo") == false
      assert GameObject.add_attribute(oid, "foo", "bar") == :ok
      assert GameObject.has_attribute?(oid, "foo") == true
      assert GameObject.remove_attribute(oid, "foo") == :ok
      assert GameObject.has_attribute?(oid, "foo") == false
    end

    @tag wip: true
    test "alias tests", %{oid: oid} = _context do
      assert GameObject.has_alias?(oid, "foo") == false
      assert GameObject.add_alias(oid, "foo") == :ok
      assert GameObject.has_alias?(oid, "foo") == true
      assert MapSet.member?(MapSet.new(GameObject.list(aliases: "foo")), oid) == true
      assert GameObject.add_alias(oid, "bar") == :ok
      assert GameObject.has_alias?(oid, "bar") == true
      assert MapSet.member?(MapSet.new(GameObject.list(aliases: ["foo", "bar"])), oid) == false
      assert GameObject.remove_alias(oid, "foo") == :ok
      assert GameObject.has_alias?(oid, "foo") == false
    end
  end

  defp create_new_game_object(_context \\ nil) do
    key = UUID.uuid4()
    {:ok, oid} = GameObject.new(key)
    %{key: key, oid: oid}
  end
end
