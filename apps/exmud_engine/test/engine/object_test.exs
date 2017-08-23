defmodule Exmud.Engine.Test.ObjectTest do
  alias Ecto.UUID
  alias Exmud.Engine.Attribute
  alias Exmud.Engine.Callback
  alias Exmud.Engine.CommandSet
  alias Exmud.Engine.Component
  alias Exmud.Engine.Object
  alias Exmud.Engine.Relationship
  alias Exmud.Engine.Repo
  alias Exmud.Engine.Tag
  require Logger
  use Exmud.Engine.Test.DBTestCase

  describe "Standard Ecto usage tests for game object: " do
    setup [:create_new_object]

    @tag object: true
    @tag engine: true
    test "bad input tests" do
      assert Object.new(0) == {:error, [key: "is invalid"]}
      assert_raise Ecto.StaleEntryError, fn ->
        Object.delete(0)
      end
    end

    @tag object: true
    @tag engine: true
    test "delete tests", %{object_id: object_id} = _context do
      assert Object.delete(object_id) == {:ok, object_id}
    end

    @tag object: true
    @tag engine: true
    test "query game object tests", %{key: key, object_id: object_id} = _context do
      invalid_key = UUID.generate()
      assert Object.query({:and, [{:object, key}]}) == {:ok, [object_id]}
      assert Object.query({:and, [{:object, invalid_key},{:object, key}]}) == {:ok, []}
      assert Object.query({:or, [{:object, invalid_key},{:object, key}]}) == {:ok, [object_id]}
      assert Object.query({:or, [
                                  {:object, invalid_key},
                                  {:and, [
                                          {:object, key},
                                          {:object, key},
                                          {:or, [
                                                  {:object, invalid_key},
                                                  {:object, key}]}]}]}) == {:ok, [object_id]}
    end

    @tag object: true
    @tag engine: true
    test "object get tests", %{object_id: object_id} = _context do
      {:ok, object} = Object.get(object_id)
      assert object.id == object_id
      component = UUID.generate()
      assert Component.register(component, Exmud.Engine.ObjectTest.ExampleComponent) == {:ok, :registered}
      callback = UUID.generate()
      assert Component.add(object_id, component) == {:ok, object_id}
      assert Attribute.add(object_id, component, "foo", "bar") == {:ok, object_id}
      assert Callback.add(object_id, callback, "bar") == {:ok, object_id}
      assert CommandSet.add(object_id, UUID.generate()) == {:ok, object_id}
      {:ok, object} = Object.get(object_id)
      assert length(object.components) == 1
      assert length(object.callbacks) == 1
    end

    @tag object: true
    @tag engine: true
    test "complex list tests to show composition", %{key: key1, object_id: object_id1} = _context do
      key2 = UUID.generate()
      {:ok, object_id2} = Object.new(key2)

      attribute_key = UUID.generate()
      attribute_value = UUID.generate()
      callback = UUID.generate()
      command_set = UUID.generate()
      component = UUID.generate()
      relationship = UUID.generate()
      tag = UUID.generate()
      tag_category = UUID.generate()

      assert Component.register(component, Exmud.Engine.ObjectTest.ExampleComponent) == {:ok, :registered}

      assert Component.add(object_id1, component) == {:ok, object_id1}
      assert Attribute.add(object_id1, component, attribute_key, attribute_value) == {:ok, object_id1}
      assert Callback.add(object_id1, callback, "bar") == {:ok, object_id1}
      assert CommandSet.add(object_id1, command_set) == {:ok, object_id1}
      assert Relationship.add(object_id1, object_id2, relationship, "foo") == {:ok, object_id1}
      assert Tag.add(object_id1, tag_category, tag) == {:ok, object_id1}

      assert Object.query({:and, [
                                    {:object, key1},
                                    {:attribute, {component, attribute_key}},
                                    {:component, component},
                                    {:callback, callback},
                                    {:command_set, command_set},
                                    {:relationship, relationship},
                                    {:relationship, {relationship, object_id2}},
                                    {:relationship, {relationship, object_id2, "foo"}},
                                    {:tag, {tag_category, tag}}
                                 ]}) == {:ok, [object_id1]}
    end
  end

  defp create_new_object(_context) do
    key = UUID.generate()
    {:ok, object_id} = Object.new(key)
    %{key: key, object_id: object_id}
  end
end


defmodule Exmud.Engine.ObjectTest.ExampleComponent do
  def populate do
    {:ok, :populated}
  end
end