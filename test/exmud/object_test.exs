defmodule Exmud.ObjectTest do
  alias Ecto.UUID
  alias Exmud.Callback
  alias Exmud.CommandSetTest.ExampleCommandSet, as: ECO
  alias Exmud.CommandSet
  alias Exmud.Object
  alias Exmud.Repo
  require Logger
  use ExUnit.Case

  describe "Standard Ecto usage tests for game object: " do
    setup [:create_new_object]

    @tag object: true
    test "bad input tests" do
      assert Object.new(0) == {:error, [key: "is invalid"]}
      assert_raise Ecto.StaleEntryError, fn ->
        Object.delete(0)
      end
    end

    @tag object: true
    test "delete tests", %{oid: oid} = _context do
      assert Object.delete(oid) == {:ok, oid}
    end

    @tag object: true
    @tag list: true
    test "list game object tests", %{key: key, oid: oid} = _context do
      invalid_key = UUID.generate()
      assert Object.list(objects: [key]) == {:ok, [oid]}
      assert Object.list(objects: [key, invalid_key]) == {:ok, []}
      assert Object.list(or_objects: [key, invalid_key]) == {:ok, [oid]}
    end

    @tag object: true
    test "complex list tests to show composition", %{oid: oid} = _context do
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
      assert Object.add_attribute(oid, attribute1, "bar") == {:ok, oid}
      assert Object.add_attribute(oid, attribute2, "bar") == {:ok, oid}
      assert Object.add_callback(oid, callback1, "bar") == {:ok, oid}
      assert Object.add_callback(oid, callback2, "bar") == {:ok, oid}
      assert Object.add_tag(oid, tag1, category) == {:ok, oid}
      assert Object.add_tag(oid, tag2, category) == {:ok, oid}
      assert Object.list(attributes: [attribute1], tags: [{tag1, category}]) == {:ok, [oid]}
      assert Object.list(attributes: [attribute1], tags: [{tag3, category}]) == {:ok, []}
      assert Object.list(attributes: [attribute1], or_tags: [{tag1, category}]) == {:ok, [oid]}
      assert Object.list(attributes: [attribute1], tags: [{:or, {tag3, category}}]) == {:ok, [oid]}
      assert Object.list(attributes: [attribute1], or_tags: [{tag3, category}]) == {:ok, [oid]}
      assert Object.list(attributes: [attribute3], tags: [{:or, {tag3, category}}]) == {:ok, []}
      assert Object.list(attributes: [attribute3, {:or, attribute2}], tags: [{:or, {tag3, category}}]) == {:ok, [oid]}
      assert Object.list(attributes: [attribute3, {:or, attribute2}], callbacks: [callback1], tags: [{:or, {tag3, category}}]) == {:ok, [oid]}
      assert Object.list(attributes: [attribute3, {:or, attribute2}], callbacks: [callback3], tags: [{:or, {tag3, category}}]) == {:ok, []}
      assert Object.list(attributes: [attribute3, {:or, attribute2}], or_callbacks: [callback3], tags: [{:or, {tag3, category}}]) == {:ok, [oid]}
    end

    @tag attribute: true
    @tag object: true
    test "attribute lifecycle", %{oid: oid} = _context do
      attribute = UUID.generate()
      attribute2 = UUID.generate()
      assert Object.add_attribute(oid, attribute, "bar") == {:ok, oid}
      assert Object.add_attribute(oid, attribute2, "bar") == {:ok, oid}
      assert Object.get_attribute(oid, attribute) == {:ok, "bar"}
      assert Object.update_attribute(oid, attribute, "foobar") == {:ok, oid}
      assert Object.get_attribute(oid, attribute) == {:ok, "foobar"}
      assert Object.has_attribute?(oid, attribute) == {:ok, true}
      assert Object.remove_attribute(oid, attribute) == {:ok, oid}
      assert Object.get_attribute(oid, attribute) == {:error, :no_such_attribute}
      assert Object.has_attribute?(oid, attribute) == {:ok, false}
    end

    @tag attribute: true
    @tag object: true
    test "attribute list tests", %{oid: oid} = _context do
      attribute1 = UUID.generate()
      attribute2 = UUID.generate()
      assert Object.list(attributes: [attribute1]) == {:ok, []}
      assert Object.add_attribute(oid, attribute1, "bar") == {:ok, oid}
      assert Object.add_attribute(oid, attribute2, "bar") == {:ok, oid}
      assert Object.list(attributes: [attribute1]) == {:ok, [oid]}
      assert Object.list(attributes: [attribute2]) == {:ok, [oid]}
      assert Object.list(attributes: [attribute1, attribute2]) == {:ok, [oid]}
    end

    @tag attribute: true
    @tag object: true
    test "attribute invalid cases", %{oid: oid} = _context do
      assert Object.get_attribute(oid, "foo") == {:error, :no_such_attribute}
      assert Object.add_attribute("invalid id", :invalid_name, "bar") ==
        {:error, [key: "is invalid", oid: "is invalid"]}
      assert Object.add_attribute(0, "foo", "bar") == {:error, [oid: "does not exist"]}
      assert Object.has_attribute?(0, "foo") == {:ok, false}
      assert Object.remove_attribute(0, "foo") == {:error, :no_such_attribute}
      assert Object.get_attribute(0, "foo") == {:error, :no_such_attribute}
    end

    @tag callback: true
    @tag object: true
    test "callback list tests", %{oid: oid} = _context do
      callback1 = UUID.generate()
      callback2 = UUID.generate()
      assert Object.list(callbacks: [callback1]) == {:ok, []}
      assert Object.add_callback(oid, callback1, "bar") == {:ok, oid}
      assert Object.add_callback(oid, callback2, "bar") == {:ok, oid}
      assert Object.list(callbacks: [callback1]) == {:ok, [oid]}
      assert Object.list(callbacks: [callback2]) == {:ok, [oid]}
      assert Object.list(callbacks: [callback1, callback2]) == {:ok, [oid]}
    end

    @tag callback: true
    @tag object: true
    test "callback lifecycle", %{oid: oid} = _context do
      assert Callback.register("foo", EC) == :ok
      assert Object.has_callback?(oid, "foo") == {:ok, false}
      assert Object.add_callback(oid, "foo", "foo") == {:ok, oid}
      assert Object.add_callback(oid, "foobar", "foo") == {:ok, oid}
      assert Object.has_callback?(oid, "foo") == {:ok, true}
      assert Object.get_callback(oid, "foo", "foobar") == {:ok, "foo"}
      assert Object.delete_callback(oid, "foo") == {:ok, oid}
      assert Object.has_callback?(oid, "foo") == {:ok, false}
    end

    @tag callback: true
    @tag object: true
    test "callback invalid cases" do
      assert Object.has_callback?(0, "foo") == {:ok, false}
      assert Object.add_callback(0, "foo", "foo") == {:error, :no_such_object}
      assert Object.get_callback(0, "foo") == {:error, :no_such_callback}
      assert Object.delete_callback(0, "foo") == {:error, :no_such_callback}
    end

    @tag command_set: true
    @tag object: true
    test "command_set list tests", %{oid: oid} = _context do
      command_set1 = UUID.generate()
      command_set2 = UUID.generate()
      assert Object.list(command_sets: [command_set1]) == {:ok, []}
      assert Object.add_command_set(oid, command_set1) == {:ok, oid}
      assert Object.add_command_set(oid, command_set2) == {:ok, oid}
      assert Object.list(command_sets: [command_set1]) == {:ok, [oid]}
      assert Object.list(command_sets: [command_set2]) == {:ok, [oid]}
      assert Object.list(command_sets: [command_set1, command_set2]) == {:ok, [oid]}
      assert Object.list(or_command_sets: [command_set1, command_set2, "foobar"]) == {:ok, [oid]}
    end

    @tag command_set: true
    @tag object: true
    test "command set on object lifecycle", %{oid: oid} = _context do
      command_set = UUID.generate()
      command_set2 = UUID.generate()
      assert Object.has_command_set?(oid, command_set) == {:ok, false}
      assert Object.add_command_set(oid, command_set) == {:ok, oid}
      assert Object.add_command_set(oid, command_set2) == {:ok, oid}
      assert Object.has_command_set?(oid, command_set) == {:ok, true}
      assert Object.delete_command_set(oid, command_set) == {:ok, oid}
      assert Object.has_command_set?(oid, command_set) == {:ok, false}
    end

    @tag command_set: true
    @tag object: true
    test "command set invalid cases" do
      assert Object.has_command_set?(0, "foo") == {:ok, false}
      assert Object.add_command_set(0, "foo") == {:error, :no_such_object}
      assert Object.delete_command_set(0, "foo") == {:error, :no_such_command_set}
    end

    @tag tag: true
    @tag object: true
    test "tag lifecycle", %{oid: oid} = _context do
      assert Object.has_tag?(oid, "foo") == {:ok, false}
      assert Object.has_tag?(oid, "foo", "bar") == {:ok, false}
      assert Object.add_tag(oid, "foo") == {:ok, oid}
      assert Object.add_tag(oid, "foo", "bar") == {:ok, oid}
      assert Object.has_tag?(oid, "foo") == {:ok, true}
      assert Object.has_tag?(oid, "foo", "bar") == {:ok, true}
      assert Object.remove_tag(oid, "foo") == {:ok, oid}
      assert Object.has_tag?(oid, "foo") == {:ok, false}
      assert Object.has_tag?(oid, "foo", "bar") == {:ok, true}
    end

    @tag tag: true
    @tag object: true
    test "tag invalid cases" do
      assert Object.add_tag("invalid id", :invalid_tag, "bar") ==
        {:error, :no_such_object}
      assert Object.has_tag?(0, "foo") == {:ok, false}
      assert Object.remove_tag(0, "foo") == {:error, :no_such_tag}
    end

    @tag tag: true
    @tag object: true
    test "tag list tests", %{oid: oid} = _context do
      tag1 = UUID.generate()
      tag2 = UUID.generate()
      category = UUID.generate()
      assert Object.list(tags: [{tag1, category}]) == {:ok, []}
      assert Object.add_tag(oid, tag1, category) == {:ok, oid}
      assert Object.add_tag(oid, tag2, category) == {:ok, oid}
      assert Object.list(tags: [{tag1, category}]) == {:ok, [oid]}
      assert Object.list(tags: [{tag2, category}]) == {:ok, [oid]}
      assert Object.list(tags: [{tag1, category}, {tag2, category}]) == {:ok, [oid]}
    end
  end

  describe "Multi Ecto usage tests for game object: " do
    setup [:create_new_object_multi]

    @tag object: true
    @tag multi: true
    test "delete tests", %{multi: multi, oid: oid} = _context do
      assert {:ok, %{"delete" => oid}} == Repo.transaction(Object.delete(multi, "delete", oid))
      assert_raise Ecto.StaleEntryError, fn ->
        Repo.transaction(Object.delete(multi, "delete", 0))
      end
    end

    @tag object: true
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
      assert Object.add_attribute(oid, attribute1, "bar") == {:ok, oid}
      assert Object.add_attribute(oid, attribute2, "bar") == {:ok, oid}
      assert Object.add_callback(oid, callback1, "bar") == {:ok, oid}
      assert Object.add_callback(oid, callback2, "bar") == {:ok, oid}
      assert Object.add_tag(oid, tag1, category) == {:ok, oid}
      assert Object.add_tag(oid, tag2, category) == {:ok, oid}

      assert Repo.transaction(Object.list(multi, "list attribute", attributes: [attribute1], tags: [{tag1, category}])) == {:ok, %{"list attribute" => [oid]}}
      assert Repo.transaction(Object.list(multi, "list attribute", attributes: [attribute1], or_tags: [{tag1, category}])) == {:ok, %{"list attribute" => [oid]}}
      assert Repo.transaction(Object.list(multi, "list attribute", attributes: [attribute1], tags: [{tag3, category}])) == {:ok, %{"list attribute" => []}}
      assert Repo.transaction(Object.list(multi, "list attribute", attributes: [attribute1], or_tags: [{tag1, category}])) == {:ok, %{"list attribute" => [oid]}}
      assert Repo.transaction(Object.list(multi, "list attribute", attributes: [attribute1], tags: [{:or, {tag3, category}}])) == {:ok, %{"list attribute" => [oid]}}
      assert Repo.transaction(Object.list(multi, "list attribute", attributes: [attribute3], tags: [{:or, {tag3, category}}])) == {:ok, %{"list attribute" => []}}
      assert Repo.transaction(Object.list(multi, "list attribute", attributes: [attribute3, {:or, attribute2}], tags: [{:or, {tag3, category}}])) == {:ok, %{"list attribute" => [oid]}}
      assert Repo.transaction(Object.list(multi, "list attribute", attributes: [attribute3, {:or, attribute2}], callbacks: [callback1], tags: [{:or, {tag3, category}}])) == {:ok, %{"list attribute" => [oid]}}
      assert Repo.transaction(Object.list(multi, "list attribute", attributes: [attribute3, {:or, attribute2}], callbacks: [callback3], tags: [{:or, {tag3, category}}])) == {:ok, %{"list attribute" => []}}
    end



    @tag attribute: true
    @tag object: true
    test "attribute lifecycle", %{multi: multi, oid: oid} = _context do
      attribute = UUID.generate()
      attribute2 = UUID.generate()
      assert Repo.transaction(Object.add_attribute(multi, "add attribute", oid, attribute, "bar")) == {:ok, %{"add attribute" => oid}}
      assert Repo.transaction(Object.add_attribute(multi, "add attribute", oid, attribute2, "bar")) == {:ok, %{"add attribute" => oid}}
      assert Repo.transaction(Object.get_attribute(multi, "get attribute", oid, attribute)) == {:ok, %{"get attribute" => "bar"}}
      assert Repo.transaction(Object.update_attribute(multi, "update attribute", oid, attribute, "foobar")) == {:ok, %{"update attribute" => oid}}
      assert Repo.transaction(Object.get_attribute(multi, "get attribute", oid, attribute)) == {:ok, %{"get attribute" => "foobar"}}
      assert Repo.transaction(Object.has_attribute?(multi, "has attribute", oid, attribute)) == {:ok, %{"has attribute" => true}}
      assert Repo.transaction(Object.remove_attribute(multi, "remove attribute", oid, attribute)) == {:ok, %{"remove attribute" => oid}}
      assert Repo.transaction(Object.get_attribute(multi, "get attribute", oid, attribute)) == {:error, "get attribute", :no_such_attribute, %{}}
      assert Repo.transaction(Object.has_attribute?(multi, "has attribute", oid, attribute)) == {:ok, %{"has attribute" => false}}
    end

    @tag attribute: true
    @tag object: true
    test "attribute list tests", %{multi: multi, oid: oid} = _context do
      attribute1 = UUID.generate()
      attribute2 = UUID.generate()
      assert Repo.transaction(Object.list(multi, "list attribute", attributes: [attribute1])) == {:ok, %{"list attribute" => []}}
      assert Repo.transaction(Object.add_attribute(multi, "add attribute", oid, attribute1, "bar")) == {:ok, %{"add attribute" => oid}}
      assert Repo.transaction(Object.add_attribute(multi, "add attribute", oid, attribute2, "bar")) == {:ok, %{"add attribute" => oid}}
      assert Repo.transaction(Object.list(multi, "list attribute", attributes: [attribute1])) == {:ok, %{"list attribute" => [oid]}}
      assert Repo.transaction(Object.list(multi, "list attribute", attributes: [attribute2])) == {:ok, %{"list attribute" => [oid]}}
      assert Repo.transaction(Object.list(multi, "list attribute", attributes: [attribute1, attribute2])) == {:ok, %{"list attribute" => [oid]}}
      assert Repo.transaction(Object.list(multi, "list attribute", attributes: [attribute1, {:or, "invalid attribute name"}])) == {:ok, %{"list attribute" => [oid]}}
      assert Repo.transaction(Object.list(multi, "list attribute", or_attributes: [attribute1, "invalid attribute name"])) == {:ok, %{"list attribute" => [oid]}}
    end

    @tag attribute: true
    @tag object: true
    test "attribute invalid cases", %{multi: multi, oid: oid} = _context do
      assert Repo.transaction(Object.get_attribute(multi, "get attribute", oid, "foo")) == {:error, "get attribute", :no_such_attribute, %{}}
      assert Repo.transaction(Object.add_attribute(multi, "add attribute", "invalid id", :invalid_name, "bar")) ==
        {:error, "add attribute", [key: "is invalid", oid: "is invalid"], %{}}
      assert Repo.transaction(Object.add_attribute(multi, "add attribute", 0, "foo", "bar")) == {:error, "add attribute", [oid: "does not exist"], %{}}
      assert Repo.transaction(Object.has_attribute?(multi, "has attribute", 0, "foo")) == {:ok, %{"has attribute" => false}}
      assert Repo.transaction(Object.remove_attribute(multi, "remove attribute", 0, "foo")) == {:error, "remove attribute", :no_such_attribute, %{}}
      assert Repo.transaction(Object.get_attribute(multi, "get attribute", 0, "foo")) == {:error, "get attribute", :no_such_attribute, %{}}
    end

    @tag callback: true
    @tag object: true
    test "callback list tests", %{multi: multi, oid: oid} = _context do
      callback1 = UUID.generate()
      callback2 = UUID.generate()
      assert Repo.transaction(Object.list(multi, "list callback", callbacks: [callback1])) == {:ok, %{"list callback" => []}}
      assert Repo.transaction(Object.add_callback(multi, "add callback", oid, callback1, "bar")) == {:ok, %{"add callback" => oid}}
      assert Repo.transaction(Object.add_callback(multi, "add callback", oid, callback2, "bar")) == {:ok, %{"add callback" => oid}}
      assert Repo.transaction(Object.list(multi, "list callback", callbacks: [callback1])) == {:ok, %{"list callback" => [oid]}}
      assert Repo.transaction(Object.list(multi, "list callback", callbacks: [callback2])) == {:ok, %{"list callback" => [oid]}}
      assert Repo.transaction(Object.list(multi, "list callback", callbacks: [callback1, callback2])) == {:ok, %{"list callback" => [oid]}}
    end

    @tag callback: true
    @tag object: true
    test "callback lifecycle", %{multi: multi, oid: oid} = _context do
      assert Repo.transaction(Object.has_callback?(multi, "has callback", oid, "foo")) == {:ok, %{"has callback" => false}}
      assert Repo.transaction(Object.add_callback(multi, "add callback", oid, "foo", "foo")) == {:ok, %{"add callback" => oid}}
      assert Repo.transaction(Object.add_callback(multi, "add callback", oid, "foobar", "foo")) == {:ok, %{"add callback" => oid}}
      assert Repo.transaction(Object.has_callback?(multi, "has callback", oid, "foo")) == {:ok, %{"has callback" => true}}
      assert Repo.transaction(Object.get_callback(multi, "get callback", oid, "foo", "foobar")) == {:ok, %{"get callback" => "foo"}}
      assert Repo.transaction(Object.delete_callback(multi, "delete callback", oid, "foo")) == {:ok, %{"delete callback" => oid}}
      assert Repo.transaction(Object.has_callback?(multi, "has callback", oid, "foo")) == {:ok, %{"has callback" => false}}
    end

    @tag callback: true
    @tag object: true
    test "callback invalid cases", %{multi: multi} = _context do
      assert Repo.transaction(Object.has_callback?(multi, "has callback", 0, "foo")) == {:ok, %{"has callback" => false}}
      assert Repo.transaction(Object.add_callback(multi, "add callback", 0, "foo", "foo")) == {:error, "add callback", :no_such_object, %{}}
      assert Repo.transaction(Object.get_callback(multi, "get callback", 0, "foo")) == {:error, "get callback", :no_such_callback, %{}}
      assert Repo.transaction(Object.delete_callback(multi, "delete callback", 0, "foo")) == {:error, "delete callback", :no_such_callback, %{}}
    end

    @tag command_set: true
    @tag object: true
    test "command_set list tests", %{multi: multi, oid: oid} = _context do
      command_set1 = UUID.generate()
      command_set2 = UUID.generate()
      assert Repo.transaction(Object.list(multi, "list command set", command_sets: [command_set1])) == {:ok, %{"list command set" => []}}
      assert Repo.transaction(Object.add_command_set(multi, "add command set", oid, command_set1)) == {:ok, %{"add command set" => oid}}
      assert Repo.transaction(Object.add_command_set(multi, "add command set", oid, command_set2)) == {:ok, %{"add command set" => oid}}
      assert Repo.transaction(Object.list(multi, "list command set", command_sets: [command_set1])) == {:ok, %{"list command set" => [oid]}}
      assert Repo.transaction(Object.list(multi, "list command set", command_sets: [command_set2])) == {:ok, %{"list command set" => [oid]}}
      assert Repo.transaction(Object.list(multi, "list command set", command_sets: [command_set1, command_set2])) == {:ok, %{"list command set" => [oid]}}
    end

    @tag command_set: true
    @tag object: true
    test "command set on object lifecycle", %{multi: multi, oid: oid} = _context do
      command_set = UUID.generate()
      command_set2 = UUID.generate()
      assert Repo.transaction(Object.has_command_set?(multi, "has command set", oid, command_set)) == {:ok, %{"has command set" => false}}
      assert Repo.transaction(Object.add_command_set(multi, "add command set", oid, command_set)) == {:ok, %{"add command set" => oid}}
      assert Repo.transaction(Object.add_command_set(multi, "add command set", oid, command_set2)) == {:ok, %{"add command set" => oid}}
      assert Repo.transaction(Object.has_command_set?(multi, "has command set", oid, command_set)) == {:ok, %{"has command set" => true}}
      assert Repo.transaction(Object.delete_command_set(multi, "delete command set", oid, command_set)) == {:ok, %{"delete command set" => oid}}
      assert Repo.transaction(Object.has_command_set?(multi, "has command set", oid, command_set)) == {:ok, %{"has command set" => false}}
    end

    @tag command_set: true
    @tag object: true
    test "command set invalid cases", %{multi: multi} = _context do
      assert Repo.transaction(Object.has_command_set?(multi, "has command set", 0, "foo")) == {:ok, %{"has command set" => false}}
      assert Repo.transaction(Object.add_command_set(multi, "add command set", 0, "foo")) == {:error, "add command set", :no_such_object, %{}}
      assert Repo.transaction(Object.delete_command_set(multi, "delete command set", 0, "foo")) == {:error, "delete command set", :no_such_command_set, %{}}
    end

    @tag tag: true
    @tag object: true
    test "tag lifecycle", %{multi: multi, oid: oid} = _context do
      assert Repo.transaction(Object.has_tag?(multi, "has tag", oid, "foo")) == {:ok, %{"has tag" => false}}
      assert Repo.transaction(Object.has_tag?(multi, "has tag", oid, "foo", "bar")) == {:ok, %{"has tag" => false}}
      assert Repo.transaction(Object.add_tag(multi, "add tag", oid, "foo")) == {:ok, %{"add tag" => oid}}
      assert Repo.transaction(Object.add_tag(multi, "add tag", oid, "foo", "bar")) == {:ok, %{"add tag" => oid}}
      assert Repo.transaction(Object.has_tag?(multi, "has tag", oid, "foo")) == {:ok, %{"has tag" => true}}
      assert Repo.transaction(Object.has_tag?(multi, "has tag", oid, "foo", "bar")) == {:ok, %{"has tag" => true}}
      assert Repo.transaction(Object.remove_tag(multi, "", oid, "foo")) == {:ok, %{"" => oid}}
      assert Repo.transaction(Object.has_tag?(multi, "has tag", oid, "foo")) == {:ok, %{"has tag" => false}}
      assert Repo.transaction(Object.has_tag?(multi, "has tag", oid, "foo", "bar")) == {:ok, %{"has tag" => true}}
    end

    @tag tag: true
    @tag object: true
    test "tag invalid cases", %{multi: multi} = _context do
      assert Repo.transaction(Object.add_tag(multi, "add tag", "invalid id", :invalid_tag, "bar")) ==
        {:error, "add tag", :no_such_object, %{}}
      assert Repo.transaction(Object.has_tag?(multi, "has tag", 0, "foo")) == {:ok, %{"has tag" => false}}
      assert Repo.transaction(Object.remove_tag(multi, "remove tag", 0, "foo")) == {:error, "remove tag", :no_such_tag, %{}}
    end

    @tag tag: true
    @tag object: true
    test "tag list tests", %{multi: multi, oid: oid} = _context do
      tag1 = UUID.generate()
      tag2 = UUID.generate()
      category = UUID.generate()
      assert Repo.transaction(Object.list(multi, "list tag", tags: [{tag1, category}])) == {:ok, %{"list tag" => []}}
      assert Repo.transaction(Object.add_tag(multi, "add tag", oid, tag1, category)) == {:ok, %{"add tag" => oid}}
      assert Repo.transaction(Object.add_tag(multi, "add tag", oid, tag2, category)) == {:ok, %{"add tag" => oid}}
      assert Repo.transaction(Object.list(multi, "list tag", tags: [{tag1, category}])) == {:ok, %{"list tag" => [oid]}}
      assert Repo.transaction(Object.list(multi, "list tag", tags: [{tag2, category}])) == {:ok, %{"list tag" => [oid]}}
      assert Repo.transaction(Object.list(multi, "list tag", tags: [{tag1, category}, {tag2, category}])) == {:ok, %{"list tag" => [oid]}}
    end
  end

  defp create_new_object(_context) do
    key = UUID.generate()
    {:ok, oid} = Object.new(key)
    %{key: key, oid: oid}
  end

  defp create_new_object_multi(_context) do
    key = UUID.generate()
    {:ok, results} = Ecto.Multi.new()
    |> Object.new("new_object", key)
    |> Repo.transaction()

    %{key: key, multi: Ecto.Multi.new(), oid: results["new_object"]}
  end
end