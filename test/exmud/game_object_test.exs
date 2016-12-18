defmodule Exmud.GameObjectTest do
  alias Ecto.UUID
  alias Exmud.Attribute
  alias Exmud.Callback
  alias Exmud.GameObject
  alias Exmud.Tag
  require Logger
  use ExUnit.Case, async: true

  describe "game object tests: " do
    setup [:create_new_game_object]

    @tag game_objects: true
    test "delete tests", %{oid: oid} = _context do
      assert GameObject.delete(oid) == :ok
      assert GameObject.delete(0) == :ok
    end

    @tag game_objects: true
    test "attribute list tests", %{oid: oid} = _context do
      attribute1 = UUID.generate()
      attribute2 = UUID.generate()
      assert GameObject.list(attributes: [attribute1]) == []
      assert Attribute.add(oid, attribute1, "bar") == :ok
      assert Attribute.add(oid, attribute2, "bar") == :ok
      assert GameObject.list(attributes: [attribute1]) == [oid]
      assert GameObject.list(attributes: [attribute2]) == [oid]
      assert GameObject.list(attributes: [attribute1, attribute2]) == [oid]
    end


    @tag game_objects: true
    test "callback list tests", %{oid: oid} = _context do
      callback1 = UUID.generate()
      callback2 = UUID.generate()
      assert GameObject.list(callbacks: [callback1]) == []
      assert Callback.add(oid, callback1, "bar") == :ok
      assert Callback.add(oid, callback2, "bar") == :ok
      assert GameObject.list(callbacks: [callback1]) == [oid]
      assert GameObject.list(callbacks: [callback2]) == [oid]
      assert GameObject.list(callbacks: [callback1, callback2]) == [oid]
    end


    @tag game_objects: true
    test "tag list tests", %{oid: oid} = _context do
      tag1 = UUID.generate()
      tag2 = UUID.generate()
      category = UUID.generate()
      assert GameObject.list(tags: [{tag1, category}]) == []
      assert Tag.add(oid, tag1, category) == :ok
      assert Tag.add(oid, tag2, category) == :ok
      assert GameObject.list(tags: [{tag1, category}]) == [oid]
      assert GameObject.list(tags: [{tag2, category}]) == [oid]
      assert GameObject.list(tags: [{tag1, category}, {tag2, category}]) == [oid]
    end


    @tag game_objects: true
    test "complex list tests", %{oid: oid} = _context do
      attribute1 = UUID.generate()
      attribute2 = UUID.generate()
      attribute3 = UUID.generate()
      callback1 = UUID.generate()
      callback2 = UUID.generate()
      callback3 = UUID.generate()
      tag1 = UUID.generate()
      tag2 = UUID.generate()
      tag3 = UUID.generate()
      category = UUID.generate()
      assert Attribute.add(oid, attribute1, "bar") == :ok
      assert Attribute.add(oid, attribute2, "bar") == :ok
      assert Callback.add(oid, callback1, "bar") == :ok
      assert Callback.add(oid, callback2, "bar") == :ok
      assert Tag.add(oid, tag1, category) == :ok
      assert Tag.add(oid, tag2, category) == :ok
      assert GameObject.list(attributes: [attribute1], tags: [{tag1, category}]) == [oid]
      assert GameObject.list(attributes: [attribute1], tags: [{tag3, category}]) == []
      assert GameObject.list(attributes: [attribute1], or_tags: [{tag1, category}]) == [oid]
      assert GameObject.list(attributes: [attribute1], tags: [{:or, {tag3, category}}]) == [oid]
      assert GameObject.list(attributes: [attribute3], tags: [{:or, {tag3, category}}]) == []
      assert GameObject.list(attributes: [attribute3, {:or, attribute2}], tags: [{:or, {tag3, category}}]) == [oid]
      assert GameObject.list(attributes: [attribute3, {:or, attribute2}], callbacks: [callback1], tags: [{:or, {tag3, category}}]) == [oid]
      assert GameObject.list(attributes: [attribute3, {:or, attribute2}], callbacks: [callback3], tags: [{:or, {tag3, category}}]) == []
    end
  end

  defp create_new_game_object(_context) do
    key = UUID.generate()
    {:ok, oid} = GameObject.new(key)
    %{key: key, oid: oid}
  end
end
