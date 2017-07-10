defmodule Exmud.Engine.Test.ObjectTest do
  alias Ecto.UUID
  alias Exmud.Engine.Callback
  alias Exmud.Engine.Object
  alias Exmud.Engine.Repo
  require Logger
  use Exmud.Engine.Test.DBTestCase

  # describe "Standard Ecto usage tests for game object: " do
  #   setup [:create_new_object]

  #   @tag object: true
  #   test "bad input tests" do
  #     assert Object.new(0) == {:error, [key: "is invalid"]}
  #     assert_raise Ecto.StaleEntryError, fn ->
  #       Object.delete(0)
  #     end
  #   end

  #   @tag object: true
  #   test "delete tests", %{oid: oid} = _context do
  #     assert Object.delete(oid) == {:ok, oid}
  #   end

  #   @tag object: true
  #   @tag list: true
  #   test "list game object tests", %{key: key, oid: oid} = _context do
  #     invalid_key = UUID.generate()
  #     assert Object.list(objects: [key]) == {:ok, [oid]}
  #     assert Object.list(objects: [key, invalid_key]) == {:ok, []}
  #     assert Object.list(or_objects: [key, invalid_key]) == {:ok, [oid]}
  #   end

  #   @tag object: true
  #   @tag get: true
  #   test "object get tests", %{oid: oid} = _context do
  #     {:ok, object} = Object.get(oid)
  #     assert object.id == oid
  #     component = UUID.generate()
  #     callback = UUID.generate()
  #     assert Component.add(oid, component) == {:ok, oid}
  #     assert Attribute.add(oid, component, "foo", "bar") == {:ok, oid}
  #     assert Callback.add(oid, callback, "bar") == {:ok, oid}
  #     assert CommandSet.add(oid, UUID.generate()) == {:ok, oid}
  #     {:ok, object} = Object.get(oid)
  #     assert length(object.components) == 1
  #     assert length(object.callbacks) == 1
  #   end

  #   @tag object: true
  #   test "complex list tests to show composition", %{oid: oid} = _context do
  #     component1 = UUID.generate()
  #     component2 = UUID.generate()
  #     component3 = UUID.generate()
  #     callback1 = UUID.generate()
  #     callback2 = UUID.generate()
  #     callback3 = UUID.generate()
  #     tag1 = UUID.generate()
  #     tag2 = UUID.generate()
  #     tag3 = UUID.generate()
  #     category = UUID.generate()
  #     assert Component.add(oid, component1) == {:ok, oid}
  #     assert Component.add(oid, component2) == {:ok, oid}
  #     assert Callback.add(oid, callback1, "bar") == {:ok, oid}
  #     assert Callback.add(oid, callback2, "bar") == {:ok, oid}
  #     assert Tag.add(oid, tag1, category) == {:ok, oid}
  #     assert Tag.add(oid, tag2, category) == {:ok, oid}
  #     assert Object.list(components: [component1], tags: [{tag1, category}]) == {:ok, [oid]}
  #     assert Object.list(components: [component1], tags: [{tag3, category}]) == {:ok, []}
  #     assert Object.list(components: [component1], or_tags: [{tag1, category}]) == {:ok, [oid]}
  #     assert Object.list(components: [component1], tags: [{:or, {tag3, category}}]) == {:ok, [oid]}
  #     assert Object.list(components: [component1], or_tags: [{tag3, category}]) == {:ok, [oid]}
  #     assert Object.list(components: [component3], tags: [{:or, {tag3, category}}]) == {:ok, []}
  #     assert Object.list(components: [component3, {:or, component2}], tags: [{:or, {tag3, category}}]) == {:ok, [oid]}
  #     assert Object.list(components: [component3, {:or, component2}], callbacks: [callback1], tags: [{:or, {tag3, category}}]) == {:ok, [oid]}
  #     assert Object.list(components: [component3, {:or, component2}], callbacks: [callback3], tags: [{:or, {tag3, category}}]) == {:ok, []}
  #     assert Object.list(components: [component3, {:or, component2}], or_callbacks: [callback3], tags: [{:or, {tag3, category}}]) == {:ok, [oid]}
  #   end

  #   @tag object: true
  #   test "callback list tests", %{oid: oid} = _context do
  #     callback1 = UUID.generate()
  #     callback2 = UUID.generate()
  #     assert Object.list(callbacks: [callback1]) == {:ok, []}
  #     assert Callback.add(oid, callback1, "bar") == {:ok, oid}
  #     assert Callback.add(oid, callback2, "bar") == {:ok, oid}
  #     assert Object.list(callbacks: [callback1]) == {:ok, [oid]}
  #     assert Object.list(callbacks: [callback2]) == {:ok, [oid]}
  #     assert Object.list(callbacks: [callback1, callback2]) == {:ok, [oid]}
  #   end
  # end

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
    test "object get tests", %{multi: multi, oid: oid} = _context do
      {:ok, %{"get" => object}} = Repo.transaction(Object.get(multi, "get", oid))
      assert object.id == oid
    end

    @tag object: true
    @tag multi: true
    test "complex list tests", %{multi: multi, oid: oid} = _context do
      component1 = UUID.generate()
      component2 = UUID.generate()
      component3 = UUID.generate()
      callback1 = UUID.generate()
      callback2 = UUID.generate()
      callback3 = UUID.generate()
      tag1 = UUID.generate()
      tag2 = UUID.generate()
      tag3 = UUID.generate()
      category = UUID.generate()
      assert Component.add(oid, component1) == {:ok, oid}
      assert Component.add(oid, component2) == {:ok, oid}
      assert Callback.add(oid, callback1, "bar") == {:ok, oid}
      assert Callback.add(oid, callback2, "bar") == {:ok, oid}
      assert Tag.add(oid, tag1, category) == {:ok, oid}
      assert Tag.add(oid, tag2, category) == {:ok, oid}

      assert Repo.transaction(Object.list(multi, "list component", components: [component1], tags: [{tag1, category}])) == {:ok, %{"list component" => [oid]}}
      assert Repo.transaction(Object.list(multi, "list component", components: [component1], or_tags: [{tag1, category}])) == {:ok, %{"list component" => [oid]}}
      assert Repo.transaction(Object.list(multi, "list component", components: [component1], tags: [{tag3, category}])) == {:ok, %{"list component" => []}}
      assert Repo.transaction(Object.list(multi, "list component", components: [component1], or_tags: [{tag1, category}])) == {:ok, %{"list component" => [oid]}}
      assert Repo.transaction(Object.list(multi, "list component", components: [component1], tags: [{:or, {tag3, category}}])) == {:ok, %{"list component" => [oid]}}
      assert Repo.transaction(Object.list(multi, "list component", components: [component3], tags: [{:or, {tag3, category}}])) == {:ok, %{"list component" => []}}
      assert Repo.transaction(Object.list(multi, "list component", components: [component3, {:or, component2}], tags: [{:or, {tag3, category}}])) == {:ok, %{"list component" => [oid]}}
      assert Repo.transaction(Object.list(multi, "list component", components: [component3, {:or, component2}], callbacks: [callback1], tags: [{:or, {tag3, category}}])) == {:ok, %{"list component" => [oid]}}
      assert Repo.transaction(Object.list(multi, "list component", components: [component3, {:or, component2}], callbacks: [callback3], tags: [{:or, {tag3, category}}])) == {:ok, %{"list component" => []}}
    end



    @tag object: true
    test "command_set list tests", %{multi: multi, oid: oid} = _context do
      command_set1 = UUID.generate()
      command_set2 = UUID.generate()
      assert Repo.transaction(Object.list(multi, "list command set", command_sets: [command_set1])) == {:ok, %{"list command set" => []}}
      assert Repo.transaction(CommandSet.add(multi, "add command set", oid, command_set1)) == {:ok, %{"add command set" => oid}}
      assert Repo.transaction(CommandSet.add(multi, "add command set", oid, command_set2)) == {:ok, %{"add command set" => oid}}
      assert Repo.transaction(Object.list(multi, "list command set", command_sets: [command_set1])) == {:ok, %{"list command set" => [oid]}}
      assert Repo.transaction(Object.list(multi, "list command set", command_sets: [command_set2])) == {:ok, %{"list command set" => [oid]}}
      assert Repo.transaction(Object.list(multi, "list command set", command_sets: [command_set1, command_set2])) == {:ok, %{"list command set" => [oid]}}
    end

    @tag object: true
    test "command set invalid cases", %{multi: multi} = _context do
      assert Repo.transaction(CommandSet.has?(multi, "has command set", 0, "foo")) == {:ok, %{"has command set" => false}}
      assert Repo.transaction(CommandSet.add(multi, "add command set", 0, "foo")) == {:error, "add command set", :no_such_object, %{}}
      assert Repo.transaction(CommandSet.delete(multi, "delete command set", 0, "foo")) == {:error, "delete command set", :no_such_command_set, %{}}
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