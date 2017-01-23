defmodule Exmud.GameObjectTest do
  alias Ecto.UUID
  alias Exmud.Callback
  alias Exmud.CommandSetTest.ExampleCommandSet, as: ECO
  alias Exmud.CommandSet
  alias Exmud.GameObject
  alias Exmud.Repo
  require Logger
  use ExUnit.Case

  describe "Standard Ecto usage tests for game object: " do
    setup [:create_new_game_object]

    @tag game_object: true
    test "delete tests", %{oid: oid} = _context do
      assert GameObject.delete(oid) == {:ok, oid}
      assert_raise Ecto.StaleEntryError, fn ->
        Repo.transaction(GameObject.delete(0))
      end
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
      assert GameObject.add_attribute(oid, attribute1, "bar") == {:ok, oid}
      assert GameObject.add_attribute(oid, attribute2, "bar") == {:ok, oid}
      assert GameObject.add_callback(oid, callback1, "bar") == {:ok, oid}
      assert GameObject.add_callback(oid, callback2, "bar") == {:ok, oid}
      assert GameObject.add_tag(oid, tag1, category) == {:ok, oid}
      assert GameObject.add_tag(oid, tag2, category) == {:ok, oid}
      assert GameObject.list(attributes: [attribute1], tags: [{tag1, category}]) == {:ok, [oid]}
      assert GameObject.list(attributes: [attribute1], tags: [{tag3, category}]) == {:ok, []}
      assert GameObject.list(attributes: [attribute1], or_tags: [{tag1, category}]) == {:ok, [oid]}
      assert GameObject.list(attributes: [attribute1], tags: [{:or, {tag3, category}}]) == {:ok, [oid]}
      assert GameObject.list(attributes: [attribute3], tags: [{:or, {tag3, category}}]) == {:ok, []}
      assert GameObject.list(attributes: [attribute3, {:or, attribute2}], tags: [{:or, {tag3, category}}]) == {:ok, [oid]}
      assert GameObject.list(attributes: [attribute3, {:or, attribute2}], callbacks: [callback1], tags: [{:or, {tag3, category}}]) == {:ok, [oid]}
      assert GameObject.list(attributes: [attribute3, {:or, attribute2}], callbacks: [callback3], tags: [{:or, {tag3, category}}]) == {:ok, []}
    end

    @tag attribute: true
    @tag game_object: true
    test "attribute lifecycle", %{oid: oid} = _context do
      attribute = UUID.generate()
      attribute2 = UUID.generate()
      assert GameObject.add_attribute(oid, attribute, "bar") == {:ok, oid}
      assert GameObject.add_attribute(oid, attribute2, "bar") == {:ok, oid}
      assert GameObject.get_attribute(oid, attribute) == {:ok, "bar"}
      assert GameObject.has_attribute?(oid, attribute) == {:ok, true}
      assert GameObject.remove_attribute(oid, attribute) == {:ok, oid}
      assert GameObject.get_attribute(oid, attribute) == {:error, :no_such_attribute}
      assert GameObject.has_attribute?(oid, attribute) == {:ok, false}
    end

    @tag attribute: true
    @tag game_object: true
    test "attribute list tests", %{oid: oid} = _context do
      attribute1 = UUID.generate()
      attribute2 = UUID.generate()
      assert GameObject.list(attributes: [attribute1]) == {:ok, []}
      assert GameObject.add_attribute(oid, attribute1, "bar") == {:ok, oid}
      assert GameObject.add_attribute(oid, attribute2, "bar") == {:ok, oid}
      assert GameObject.list(attributes: [attribute1]) == {:ok, [oid]}
      assert GameObject.list(attributes: [attribute2]) == {:ok, [oid]}
      assert GameObject.list(attributes: [attribute1, attribute2]) == {:ok, [oid]}
    end

    @tag attribute: true
    @tag game_object: true
    test "attribute invalid cases", %{oid: oid} = _context do
      assert GameObject.get_attribute(oid, "foo") == {:error, :no_such_attribute}
      assert GameObject.add_attribute("invalid id", :invalid_name, "bar") ==
        {:error, [key: "is invalid", oid: "is invalid"]}
      assert GameObject.add_attribute(0, "foo", "bar") == {:error, [oid: "does not exist"]}
      assert GameObject.has_attribute?(0, "foo") == {:ok, false}
      assert GameObject.remove_attribute(0, "foo") == {:error, :no_such_attribute}
      assert GameObject.get_attribute(0, "foo") == {:error, :no_such_attribute}
    end

    @tag callback: true
    @tag game_object: true
    test "callback list tests", %{oid: oid} = _context do
      callback1 = UUID.generate()
      callback2 = UUID.generate()
      assert GameObject.list(callbacks: [callback1]) == {:ok, []}
      assert GameObject.add_callback(oid, callback1, "bar") == {:ok, oid}
      assert GameObject.add_callback(oid, callback2, "bar") == {:ok, oid}
      assert GameObject.list(callbacks: [callback1]) == {:ok, [oid]}
      assert GameObject.list(callbacks: [callback2]) == {:ok, [oid]}
      assert GameObject.list(callbacks: [callback1, callback2]) == {:ok, [oid]}
    end

    @tag callback: true
    @tag game_object: true
    test "callback lifecycle", %{oid: oid} = _context do
      assert Callback.register("foo", EC) == :ok
      assert GameObject.has_callback?(oid, "foo") == {:ok, false}
      assert GameObject.add_callback(oid, "foo", "foo") == {:ok, oid}
      assert GameObject.add_callback(oid, "foobar", "foo") == {:ok, oid}
      assert GameObject.has_callback?(oid, "foo") == {:ok, true}
      assert GameObject.get_callback(oid, "foo", "foobar") == {:ok, EC}
      assert GameObject.delete_callback(oid, "foo") == {:ok, oid}
      assert GameObject.has_callback?(oid, "foo") == {:ok, false}
    end

    @tag callback: true
    @tag game_object: true
    test "callback invalid cases" do
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
      assert GameObject.list(command_sets: [command_set1]) == {:ok, []}
      assert GameObject.add_command_set(oid, command_set1) == {:ok, oid}
      assert GameObject.add_command_set(oid, command_set2) == {:ok, oid}
      assert GameObject.list(command_sets: [command_set1]) == {:ok, [oid]}
      assert GameObject.list(command_sets: [command_set2]) == {:ok, [oid]}
      assert GameObject.list(command_sets: [command_set1, command_set2]) == {:ok, [oid]}
    end

    @tag command_set: true
    @tag game_object: true
    test "command set on object lifecycle", %{oid: oid} = _context do
      command_set = UUID.generate()
      command_set2 = UUID.generate()
      assert CommandSet.register(command_set, ECO) == :ok
      assert GameObject.has_command_set?(oid, command_set) == {:ok, false}
      assert GameObject.add_command_set(oid, command_set) == {:ok, oid}
      assert GameObject.add_command_set(oid, command_set2) == {:ok, oid}
      assert GameObject.has_command_set?(oid, command_set) == {:ok, true}
      assert GameObject.delete_command_set(oid, command_set) == {:ok, oid}
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
      assert GameObject.add_tag(oid, "foo") == {:ok, oid}
      assert GameObject.add_tag(oid, "foo", "bar") == {:ok, oid}
      assert GameObject.has_tag?(oid, "foo") == {:ok, true}
      assert GameObject.has_tag?(oid, "foo", "bar") == {:ok, true}
      assert GameObject.remove_tag(oid, "foo") == {:ok, oid}
      assert GameObject.has_tag?(oid, "foo") == {:ok, false}
      assert GameObject.has_tag?(oid, "foo", "bar") == {:ok, true}
    end

    @tag tag: true
    @tag game_object: true
    test "tag invalid cases" do
      assert GameObject.add_tag("invalid id", :invalid_tag, "bar") ==
        {:error, :no_such_game_object}
      assert GameObject.has_tag?(0, "foo") == {:ok, false}
      assert GameObject.remove_tag(0, "foo") == {:error, :no_such_tag}
    end

    @tag tag: true
    @tag game_object: true
    test "tag list tests", %{oid: oid} = _context do
      tag1 = UUID.generate()
      tag2 = UUID.generate()
      category = UUID.generate()
      assert GameObject.list(tags: [{tag1, category}]) == {:ok, []}
      assert GameObject.add_tag(oid, tag1, category) == {:ok, oid}
      assert GameObject.add_tag(oid, tag2, category) == {:ok, oid}
      assert GameObject.list(tags: [{tag1, category}]) == {:ok, [oid]}
      assert GameObject.list(tags: [{tag2, category}]) == {:ok, [oid]}
      assert GameObject.list(tags: [{tag1, category}, {tag2, category}]) == {:ok, [oid]}
    end
  end

  describe "Multi Ecto usage tests for game object: " do
    setup [:create_new_game_object_multi]

    @tag game_object: true
    @tag multi: true
    test "delete tests", %{multi: multi, oid: oid} = _context do
      assert {:ok, %{"delete" => oid}} == Repo.transaction(GameObject.delete(multi, "delete", oid))
      assert_raise Ecto.StaleEntryError, fn ->
        Repo.transaction(GameObject.delete(multi, "delete", 0))
      end
    end

    @tag game_object: true
    @tag multi: true
    test "complex list tests", %{multi: multi, oid: oid} = _context do
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
      assert GameObject.add_attribute(oid, attribute1, "bar") == {:ok, oid}
      assert GameObject.add_attribute(oid, attribute2, "bar") == {:ok, oid}
      assert GameObject.add_callback(oid, callback1, "bar") == {:ok, oid}
      assert GameObject.add_callback(oid, callback2, "bar") == {:ok, oid}
      assert GameObject.add_tag(oid, tag1, category) == {:ok, oid}
      assert GameObject.add_tag(oid, tag2, category) == {:ok, oid}

      assert Repo.transaction(GameObject.list(multi, "list attribute", attributes: [attribute1], tags: [{tag1, category}])) == {:ok, %{"list attribute" => [oid]}}
      assert Repo.transaction(GameObject.list(multi, "list attribute", attributes: [attribute1], or_tags: [{tag1, category}])) == {:ok, %{"list attribute" => [oid]}}
      assert Repo.transaction(GameObject.list(multi, "list attribute", attributes: [attribute1], tags: [{tag3, category}])) == {:ok, %{"list attribute" => []}}
      assert Repo.transaction(GameObject.list(multi, "list attribute", attributes: [attribute1], or_tags: [{tag1, category}])) == {:ok, %{"list attribute" => [oid]}}
      assert Repo.transaction(GameObject.list(multi, "list attribute", attributes: [attribute1], tags: [{:or, {tag3, category}}])) == {:ok, %{"list attribute" => [oid]}}
      assert Repo.transaction(GameObject.list(multi, "list attribute", attributes: [attribute3], tags: [{:or, {tag3, category}}])) == {:ok, %{"list attribute" => []}}
      assert Repo.transaction(GameObject.list(multi, "list attribute", attributes: [attribute3, {:or, attribute2}], tags: [{:or, {tag3, category}}])) == {:ok, %{"list attribute" => [oid]}}
      assert Repo.transaction(GameObject.list(multi, "list attribute", attributes: [attribute3, {:or, attribute2}], callbacks: [callback1], tags: [{:or, {tag3, category}}])) == {:ok, %{"list attribute" => [oid]}}
      assert Repo.transaction(GameObject.list(multi, "list attribute", attributes: [attribute3, {:or, attribute2}], callbacks: [callback3], tags: [{:or, {tag3, category}}])) == {:ok, %{"list attribute" => []}}
    end



    @tag attribute: true
    @tag game_object: true
    test "attribute lifecycle", %{multi: multi, oid: oid} = _context do
      attribute = UUID.generate()
      attribute2 = UUID.generate()
      assert Repo.transaction(GameObject.add_attribute(multi, "add attribute", oid, attribute, "bar")) == {:ok, %{"add attribute" => oid}}
      assert Repo.transaction(GameObject.add_attribute(multi, "add attribute", oid, attribute2, "bar")) == {:ok, %{"add attribute" => oid}}
      assert Repo.transaction(GameObject.get_attribute(multi, "get attribute", oid, attribute)) == {:ok, %{"get attribute" => "bar"}}
      assert Repo.transaction(GameObject.has_attribute?(multi, "has attribute", oid, attribute)) == {:ok, %{"has attribute" => true}}
      assert Repo.transaction(GameObject.remove_attribute(multi, "remove attribute", oid, attribute)) == {:ok, %{"remove attribute" => oid}}
      assert Repo.transaction(GameObject.get_attribute(multi, "get attribute", oid, attribute)) == {:error, "get attribute", :no_such_attribute, %{}}
      assert Repo.transaction(GameObject.has_attribute?(multi, "has attribute", oid, attribute)) == {:ok, %{"has attribute" => false}}
    end

    @tag attribute: true
    @tag game_object: true
    test "attribute list tests", %{multi: multi, oid: oid} = _context do
      attribute1 = UUID.generate()
      attribute2 = UUID.generate()
      assert Repo.transaction(GameObject.list(multi, "list attribute", attributes: [attribute1])) == {:ok, %{"list attribute" => []}}
      assert Repo.transaction(GameObject.add_attribute(multi, "add attribute", oid, attribute1, "bar")) == {:ok, %{"add attribute" => oid}}
      assert Repo.transaction(GameObject.add_attribute(multi, "add attribute", oid, attribute2, "bar")) == {:ok, %{"add attribute" => oid}}
      assert Repo.transaction(GameObject.list(multi, "list attribute", attributes: [attribute1])) == {:ok, %{"list attribute" => [oid]}}
      assert Repo.transaction(GameObject.list(multi, "list attribute", attributes: [attribute2])) == {:ok, %{"list attribute" => [oid]}}
      assert Repo.transaction(GameObject.list(multi, "list attribute", attributes: [attribute1, attribute2])) == {:ok, %{"list attribute" => [oid]}}
    end

    @tag attribute: true
    @tag game_object: true
    test "attribute invalid cases", %{multi: multi, oid: oid} = _context do
      assert Repo.transaction(GameObject.get_attribute(multi, "get attribute", oid, "foo")) == {:error, "get attribute", :no_such_attribute, %{}}
      assert Repo.transaction(GameObject.add_attribute(multi, "add attribute", "invalid id", :invalid_name, "bar")) ==
        {:error, "add attribute", [key: "is invalid", oid: "is invalid"], %{}}
      assert Repo.transaction(GameObject.add_attribute(multi, "add attribute", 0, "foo", "bar")) == {:error, "add attribute", [oid: "does not exist"], %{}}
      assert Repo.transaction(GameObject.has_attribute?(multi, "has attribute", 0, "foo")) == {:ok, %{"has attribute" => false}}
      assert Repo.transaction(GameObject.remove_attribute(multi, "remove attribute", 0, "foo")) == {:error, "remove attribute", :no_such_attribute, %{}}
      assert Repo.transaction(GameObject.get_attribute(multi, "get attribute", 0, "foo")) == {:error, "get attribute", :no_such_attribute, %{}}
    end

    @tag callback: true
    @tag game_object: true
    test "callback list tests", %{multi: multi, oid: oid} = _context do
      callback1 = UUID.generate()
      callback2 = UUID.generate()
      assert Repo.transaction(GameObject.list(multi, "list callback", callbacks: [callback1])) == {:ok, %{"list callback" => []}}
      assert Repo.transaction(GameObject.add_callback(multi, "add callback", oid, callback1, "bar")) == {:ok, %{"add callback" => oid}}
      assert Repo.transaction(GameObject.add_callback(multi, "add callback", oid, callback2, "bar")) == {:ok, %{"add callback" => oid}}
      assert Repo.transaction(GameObject.list(multi, "list callback", callbacks: [callback1])) == {:ok, %{"list callback" => [oid]}}
      assert Repo.transaction(GameObject.list(multi, "list callback", callbacks: [callback2])) == {:ok, %{"list callback" => [oid]}}
      assert Repo.transaction(GameObject.list(multi, "list callback", callbacks: [callback1, callback2])) == {:ok, %{"list callback" => [oid]}}
    end

    @tag callback: true
    @tag game_object: true
    test "callback lifecycle", %{multi: multi, oid: oid} = _context do
      assert Callback.register("foo", EC) == :ok
      assert Repo.transaction(GameObject.has_callback?(multi, "has callback", oid, "foo")) == {:ok, %{"has callback" => false}}
      assert Repo.transaction(GameObject.add_callback(multi, "add callback", oid, "foo", "foo")) == {:ok, %{"add callback" => oid}}
      assert Repo.transaction(GameObject.add_callback(multi, "add callback", oid, "foobar", "foo")) == {:ok, %{"add callback" => oid}}
      assert Repo.transaction(GameObject.has_callback?(multi, "has callback", oid, "foo")) == {:ok, %{"has callback" => true}}
      assert Repo.transaction(GameObject.get_callback(multi, "get callback", oid, "foo", "foobar")) == {:ok, %{"get callback" => EC}}
      assert Repo.transaction(GameObject.delete_callback(multi, "delete callback", oid, "foo")) == {:ok, %{"delete callback" => oid}}
      assert Repo.transaction(GameObject.has_callback?(multi, "has callback", oid, "foo")) == {:ok, %{"has callback" => false}}
    end

    @tag callback: true
    @tag game_object: true
    test "callback invalid cases", %{multi: multi} = _context do
      assert Repo.transaction(GameObject.has_callback?(multi, "has callback", 0, "foo")) == {:ok, %{"has callback" => false}}
      assert Repo.transaction(GameObject.add_callback(multi, "add callback", 0, "foo", "foo")) == {:error, "add callback", :no_such_game_object, %{}}
      assert Repo.transaction(GameObject.get_callback(multi, "get callback", 0, "foo", "foobar")) == {:error, "get callback", :no_such_callback, %{}}
      assert Repo.transaction(GameObject.delete_callback(multi, "delete callback", 0, "foo")) == {:error, "delete callback", :no_such_callback, %{}}
    end

    @tag command_set: true
    @tag game_object: true
    test "command_set list tests", %{multi: multi, oid: oid} = _context do
      command_set1 = UUID.generate()
      command_set2 = UUID.generate()
      assert Repo.transaction(GameObject.list(multi, "list command set", command_sets: [command_set1])) == {:ok, %{"list command set" => []}}
      assert Repo.transaction(GameObject.add_command_set(multi, "add command set", oid, command_set1)) == {:ok, %{"add command set" => oid}}
      assert Repo.transaction(GameObject.add_command_set(multi, "add command set", oid, command_set2)) == {:ok, %{"add command set" => oid}}
      assert Repo.transaction(GameObject.list(multi, "list command set", command_sets: [command_set1])) == {:ok, %{"list command set" => [oid]}}
      assert Repo.transaction(GameObject.list(multi, "list command set", command_sets: [command_set2])) == {:ok, %{"list command set" => [oid]}}
      assert Repo.transaction(GameObject.list(multi, "list command set", command_sets: [command_set1, command_set2])) == {:ok, %{"list command set" => [oid]}}
    end

    @tag command_set: true
    @tag game_object: true
    test "command set on object lifecycle", %{multi: multi, oid: oid} = _context do
      command_set = UUID.generate()
      command_set2 = UUID.generate()
      assert CommandSet.register(command_set, ECO) == :ok
      assert Repo.transaction(GameObject.has_command_set?(multi, "has command set", oid, command_set)) == {:ok, %{"has command set" => false}}
      assert Repo.transaction(GameObject.add_command_set(multi, "add command set", oid, command_set)) == {:ok, %{"add command set" => oid}}
      assert Repo.transaction(GameObject.add_command_set(multi, "add command set", oid, command_set2)) == {:ok, %{"add command set" => oid}}
      assert Repo.transaction(GameObject.has_command_set?(multi, "has command set", oid, command_set)) == {:ok, %{"has command set" => true}}
      assert Repo.transaction(GameObject.delete_command_set(multi, "delete command set", oid, command_set)) == {:ok, %{"delete command set" => oid}}
      assert Repo.transaction(GameObject.has_command_set?(multi, "has command set", oid, command_set)) == {:ok, %{"has command set" => false}}
    end

    @tag command_set: true
    @tag game_object: true
    test "command set invalid cases", %{multi: multi} = _context do
      assert Repo.transaction(GameObject.has_command_set?(multi, "has command set", 0, "foo")) == {:ok, %{"has command set" => false}}
      assert Repo.transaction(GameObject.add_command_set(multi, "add command set", 0, "foo")) == {:error, "add command set", :no_such_game_object, %{}}
      assert Repo.transaction(GameObject.delete_command_set(multi, "delete command set", 0, "foo")) == {:error, "delete command set", :no_such_command_set, %{}}
    end

    @tag tag: true
    @tag game_object: true
    test "tag lifecycle", %{multi: multi, oid: oid} = _context do
      assert Repo.transaction(GameObject.has_tag?(multi, "has tag", oid, "foo")) == {:ok, %{"has tag" => false}}
      assert Repo.transaction(GameObject.has_tag?(multi, "has tag", oid, "foo", "bar")) == {:ok, %{"has tag" => false}}
      assert Repo.transaction(GameObject.add_tag(multi, "add tag", oid, "foo")) == {:ok, %{"add tag" => oid}}
      assert Repo.transaction(GameObject.add_tag(multi, "add tag", oid, "foo", "bar")) == {:ok, %{"add tag" => oid}}
      assert Repo.transaction(GameObject.has_tag?(multi, "has tag", oid, "foo")) == {:ok, %{"has tag" => true}}
      assert Repo.transaction(GameObject.has_tag?(multi, "has tag", oid, "foo", "bar")) == {:ok, %{"has tag" => true}}
      assert Repo.transaction(GameObject.remove_tag(multi, "", oid, "foo")) == {:ok, %{"" => oid}}
      assert Repo.transaction(GameObject.has_tag?(multi, "has tag", oid, "foo")) == {:ok, %{"has tag" => false}}
      assert Repo.transaction(GameObject.has_tag?(multi, "has tag", oid, "foo", "bar")) == {:ok, %{"has tag" => true}}
    end

    @tag tag: true
    @tag game_object: true
    test "tag invalid cases", %{multi: multi} = _context do
      assert Repo.transaction(GameObject.add_tag(multi, "add tag", "invalid id", :invalid_tag, "bar")) ==
        {:error, "add tag", :no_such_game_object, %{}}
      assert Repo.transaction(GameObject.has_tag?(multi, "has tag", 0, "foo")) == {:ok, %{"has tag" => false}}
      assert Repo.transaction(GameObject.remove_tag(multi, "remove tag", 0, "foo")) == {:error, "remove tag", :no_such_tag, %{}}
    end

    @tag tag: true
    @tag game_object: true
    test "tag list tests", %{multi: multi, oid: oid} = _context do
      tag1 = UUID.generate()
      tag2 = UUID.generate()
      category = UUID.generate()
      assert Repo.transaction(GameObject.list(multi, "list tag", tags: [{tag1, category}])) == {:ok, %{"list tag" => []}}
      assert Repo.transaction(GameObject.add_tag(multi, "add tag", oid, tag1, category)) == {:ok, %{"add tag" => oid}}
      assert Repo.transaction(GameObject.add_tag(multi, "add tag", oid, tag2, category)) == {:ok, %{"add tag" => oid}}
      assert Repo.transaction(GameObject.list(multi, "list tag", tags: [{tag1, category}])) == {:ok, %{"list tag" => [oid]}}
      assert Repo.transaction(GameObject.list(multi, "list tag", tags: [{tag2, category}])) == {:ok, %{"list tag" => [oid]}}
      assert Repo.transaction(GameObject.list(multi, "list tag", tags: [{tag1, category}, {tag2, category}])) == {:ok, %{"list tag" => [oid]}}
    end
  end

  defp create_new_game_object(_context) do
    key = UUID.generate()
    {:ok, oid} = GameObject.new(key)
    %{key: key, oid: oid}
  end

  defp create_new_game_object_multi(_context) do
    key = UUID.generate()
    {:ok, results} = Ecto.Multi.new()
    |> GameObject.new("new_game_object", key)
    |> Repo.transaction()

    %{key: key, multi: Ecto.Multi.new(), oid: results["new_game_object"]}
  end
end
