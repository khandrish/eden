defmodule Exmud.GameObjectTest do
  alias Ecto.UUID
  alias Exmud.Attribute
  alias Exmud.Callback
  alias Exmud.CallbackTest.ExampleCallback, as: ECA
  alias Exmud.CommandSetTest.ExampleCommandSet, as: ECO
  alias Exmud.CommandSet
  alias Exmud.GameObject
  alias Exmud.Tag
  require Logger
  use ExUnit.Case

  describe "game object tests: " do
    setup [:create_new_game_object]

    @tag game_object: true
    test "delete tests", %{oid: oid} = _context do
      assert GameObject.delete(oid) == :ok
      assert GameObject.delete(0) == :ok
    end

    @tag game_object: true
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
      assert GameObject.add_attribute(oid, attribute1, "bar") == :ok
      assert GameObject.add_attribute(oid, attribute2, "bar") == :ok
      assert GameObject.add_callback(oid, callback1, "bar") == :ok
      assert GameObject.add_callback(oid, callback2, "bar") == :ok
      assert GameObject.add_tag(oid, tag1, category) == :ok
      assert GameObject.add_tag(oid, tag2, category) == :ok
      assert GameObject.list(attributes: [attribute1], tags: [{tag1, category}]) == [oid]
      assert GameObject.list(attributes: [attribute1], tags: [{tag3, category}]) == []
      assert GameObject.list(attributes: [attribute1], or_tags: [{tag1, category}]) == [oid]
      assert GameObject.list(attributes: [attribute1], tags: [{:or, {tag3, category}}]) == [oid]
      assert GameObject.list(attributes: [attribute3], tags: [{:or, {tag3, category}}]) == []
      assert GameObject.list(attributes: [attribute3, {:or, attribute2}], tags: [{:or, {tag3, category}}]) == [oid]
      assert GameObject.list(attributes: [attribute3, {:or, attribute2}], callbacks: [callback1], tags: [{:or, {tag3, category}}]) == [oid]
      assert GameObject.list(attributes: [attribute3, {:or, attribute2}], callbacks: [callback3], tags: [{:or, {tag3, category}}]) == []
    end

    @tag attribute: true
    @tag game_object: true
    test "attribute lifecycle", %{oid: oid} = _context do
      attribute = UUID.generate()
      attribute2 = UUID.generate()
      assert GameObject.add_attribute(oid, attribute, "bar") == :ok
      assert GameObject.add_attribute(oid, attribute2, "bar") == :ok
      assert GameObject.get_attribute(oid, attribute) == {:ok, "bar"}
      assert GameObject.has_attribute?(oid, attribute) == {:ok, true}
      assert GameObject.remove_attribute(oid, attribute) == :ok
      assert GameObject.get_attribute(oid, attribute) == {:error, :no_such_attribute}
      assert GameObject.has_attribute?(oid, attribute) == {:ok, false}
    end

    @tag attribute: true
    @tag game_object: true
    test "attribute list tests", %{oid: oid} = _context do
      attribute1 = UUID.generate()
      attribute2 = UUID.generate()
      assert GameObject.list(attributes: [attribute1]) == []
      assert GameObject.add_attribute(oid, attribute1, "bar") == :ok
      assert GameObject.add_attribute(oid, attribute2, "bar") == :ok
      assert GameObject.list(attributes: [attribute1]) == [oid]
      assert GameObject.list(attributes: [attribute2]) == [oid]
      assert GameObject.list(attributes: [attribute1, attribute2]) == [oid]
    end

    @tag attribute: true
    @tag game_object: true
    test "attribute invalid cases", %{oid: oid} = _context do
      assert GameObject.get_attribute(oid, "foo") == {:error, :no_such_attribute}
      assert GameObject.add_attribute("invalid id", :invalid_name, "bar") ==
        {:error,
          [key: {"is invalid", [type: :string, validation: :cast]},
           oid: {"is invalid", [type: :id, validation: :cast]}]}
      assert GameObject.add_attribute(0, "foo", "bar") == {:error, [oid: {"does not exist", []}]}
      assert GameObject.has_attribute?(0, "foo") == {:ok, false}
      assert GameObject.remove_attribute(0, "foo") == {:error, :no_such_attribute}
      assert GameObject.get_attribute(0, "foo") == {:error, :no_such_attribute}
    end

    @tag callback: true
    @tag game_object: true
    test "callback list tests", %{oid: oid} = _context do
      callback1 = UUID.generate()
      callback2 = UUID.generate()
      assert GameObject.list(callbacks: [callback1]) == []
      assert GameObject.add_callback(oid, callback1, "bar") == :ok
      assert GameObject.add_callback(oid, callback2, "bar") == :ok
      assert GameObject.list(callbacks: [callback1]) == [oid]
      assert GameObject.list(callbacks: [callback2]) == [oid]
      assert GameObject.list(callbacks: [callback1, callback2]) == [oid]
    end
    
    @tag callback: true
    @tag game_object: true
    test "callback lifecycle", %{oid: oid} = _context do
      assert Callback.register("foo", EC) == :ok
      assert GameObject.has_callback?(oid, "foo") == {:ok, false}
      assert GameObject.add_callback(oid, "foo", "foo") == :ok
      assert GameObject.add_callback(oid, "foobar", "foo") == :ok
      assert GameObject.has_callback?(oid, "foo") == {:ok, true}
      assert GameObject.get_callback(oid, "foo", "foobar") == {:ok, EC}
      assert GameObject.delete_callback(oid, "foo") == :ok
      assert GameObject.has_callback?(oid, "foo") == {:ok, false}
    end
    
    @tag callback: true
    @tag game_object: true
    test "callback invalid cases", %{oid: oid} = _context do
      assert GameObject.has_callback?(0, "foo") == {:ok, false}
      assert GameObject.add_callback(0, "foo", "foo") == {:error, :no_such_game_object}
      assert GameObject.get_callback(0, "foo", "foobar") == {:error, :no_such_callback}
      assert GameObject.delete_callback(0, "foo") == {:error, :no_such_callback}
    end

    @tag command_set: true
    @tag game_object: true
    test "command_set list tests", %{oid: oid} = _context do
      command_set1 = UUID.generate()
      command_set2 = UUID.generate()
      assert GameObject.list(command_sets: [command_set1]) == []
      assert GameObject.add_command_set(oid, command_set1) == :ok
      assert GameObject.add_command_set(oid, command_set2) == :ok
      assert GameObject.list(command_sets: [command_set1]) == [oid]
      assert GameObject.list(command_sets: [command_set2]) == [oid]
      assert GameObject.list(command_sets: [command_set1, command_set2]) == [oid]
    end
    
    @tag command_set: true
    @tag game_object: true
    test "command set on object lifecycle", %{oid: oid} = _context do
      command_set = UUID.generate()
      command_set2 = UUID.generate()
      assert CommandSet.register(command_set, ECO) == :ok
      assert GameObject.has_command_set?(oid, command_set) == {:ok, false}
      assert GameObject.add_command_set(oid, command_set) == :ok
      assert GameObject.add_command_set(oid, command_set2) == :ok
      assert GameObject.has_command_set?(oid, command_set) == {:ok, true}
      assert GameObject.delete_command_set(oid, command_set) == :ok
      assert GameObject.has_command_set?(oid, command_set) == {:ok, false}
    end
    
    @tag command_set: true
    @tag game_object: true
    test "command set invalid cases" do
      assert GameObject.has_command_set?(0, "foo") == {:ok, false}
      assert GameObject.add_command_set(0, "foo") == {:error, :no_such_game_object}
      assert GameObject.delete_command_set(0, "foo") == {:error, :no_such_command_set}
    end
    
    @tag tag: true
    @tag game_object: true
    test "tag lifecycle", %{oid: oid} = _context do
      assert GameObject.has_tag?(oid, "foo") == {:ok, false}
      assert GameObject.has_tag?(oid, "foo", "bar") == {:ok, false}
      assert GameObject.add_tag(oid, "foo") == :ok
      assert GameObject.add_tag(oid, "foo", "bar") == :ok
      assert GameObject.has_tag?(oid, "foo") == {:ok, true}
      assert GameObject.has_tag?(oid, "foo", "bar") == {:ok, true}
      assert GameObject.remove_tag(oid, "foo") == :ok
      assert GameObject.has_tag?(oid, "foo") == {:ok, false}
      assert GameObject.has_tag?(oid, "foo", "bar") == {:ok, true}
    end
    
    @tag tag: true
    @tag game_object: true
    test "tag invalid cases" do
      assert GameObject.add_tag("invalid id", :invalid_tag, "bar") ==
        {:error,
          [oid: {"is invalid", [type: :id, validation: :cast]},
           key: {"is invalid", [type: :string, validation: :cast]}]}
      assert GameObject.has_tag?(0, "foo") == {:ok, false}
      assert GameObject.remove_tag(0, "foo") == {:error, :no_such_tag}
    end
    
    @tag tag: true
    @tag game_object: true
    test "tag list tests", %{oid: oid} = _context do
      tag1 = UUID.generate()
      tag2 = UUID.generate()
      category = UUID.generate()
      assert GameObject.list(tags: [{tag1, category}]) == []
      assert GameObject.add_tag(oid, tag1, category) == :ok
      assert GameObject.add_tag(oid, tag2, category) == :ok
      assert GameObject.list(tags: [{tag1, category}]) == [oid]
      assert GameObject.list(tags: [{tag2, category}]) == [oid]
      assert GameObject.list(tags: [{tag1, category}, {tag2, category}]) == [oid]
    end
  end

  defp create_new_game_object(_context) do
    key = UUID.generate()
    {:ok, oid} = GameObject.new(key)
    %{key: key, oid: oid}
  end
end
