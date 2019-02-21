defmodule Exmud.Engine.Test.ObjectTest do
  alias Ecto.UUID
  alias Exmud.Engine.Attribute
  alias Exmud.Engine.CommandSet
  alias Exmud.Engine.Component
  alias Exmud.Engine.Object
  alias Exmud.Engine.Link
  alias Exmud.Engine.Repo
  alias Exmud.Engine.Tag
  require Logger
  use Exmud.Engine.Test.DBTestCase

  # Test Callbacks
  alias Exmud.Engine.Test.CommandSet.Basic, as: BasicCommandSet

  # Test Component
  alias Exmud.Engine.Test.Component.Basic, as: BasicComponent

  describe "Objects: " do
    setup [:create_new_object]

    @tag object: true
    @tag engine: true
    test "Delete an Object which doesn't exist" do
      assert Object.delete(0) == {:error, :no_such_object}
    end

    @tag object: true
    @tag engine: true
    test "delete tests", %{object_id: object_id} = _context do
      assert Object.delete(object_id) == :ok
    end

    @tag object: true
    @tag engine: true
    test "object get tests", %{object_id: object_id} = _context do
      {:ok, object} = Object.get(object_id)
      assert object.id == object_id
      assert Component.attach(object_id, BasicComponent) == :ok
      assert Attribute.put(object_id, BasicComponent, "foo", "bar") == :ok
      assert CommandSet.attach(object_id, BasicCommandSet) == :ok
      {:ok, object} = Object.get(object_id)
      assert length(object.components) == 1
    end

    @tag object: true
    @tag engine: true
    test "complex list tests to show composition", %{object_id: object_id1} = _context do
      object_id2 = Object.new!()

      attribute_key = UUID.generate()
      attribute_value = UUID.generate()
      link_type = UUID.generate()
      tag = UUID.generate()
      tag_category = UUID.generate()

      assert Component.attach(object_id1, BasicComponent) == :ok

      assert Attribute.put(object_id1, BasicComponent, attribute_key, attribute_value) ==
               :ok

      assert CommandSet.attach(object_id1, BasicCommandSet) == :ok
      assert Link.forge(object_id1, object_id2, link_type, "foo") == :ok
      assert Tag.attach(object_id1, tag_category, tag) == :ok

      assert Object.query(
               {:and,
                [
                  {:attribute, {BasicComponent, attribute_key}},
                  {:component, BasicComponent},
                  {:command_set, BasicCommandSet},
                  {:link, link_type},
                  {:link, {link_type, {:to, object_id2}}},
                  {:link, {link_type, {:to, object_id2}, "foo"}},
                  {:tag, {tag_category, tag}}
                ]}
             ) == {:ok, [object_id1]}
    end

    @tag wip: true
    test "query game object tests", %{object_id: object_id} = _context do
      object_id2 = Object.new!()

      attribute_key = UUID.generate()
      attribute_value = UUID.generate()
      link_type = UUID.generate()
      tag = UUID.generate()
      tag_category = UUID.generate()

      assert Component.attach(object_id, BasicComponent) == :ok

      assert Attribute.put(object_id, BasicComponent, attribute_key, attribute_value) == :ok

      assert CommandSet.attach(object_id, BasicCommandSet) == :ok
      assert Link.forge(object_id, object_id2, link_type, "foo") == :ok
      assert Tag.attach(object_id, tag_category, tag) == :ok

      assert Object.query(
               {:and,
                [
                  {:attribute, {BasicComponent, attribute_key}},
                  {:component, BasicComponent},
                  {:command_set, BasicCommandSet},
                  {:or,
                   [
                     {:link, link_type},
                     {:link, {link_type, {:to, object_id2}}},
                     {:link, {link_type, {:from, object_id}, "foo"}},
                     {:tag, {tag_category, tag}}
                   ]}
                ]}
             ) == {:ok, [object_id]}

      {:ok, object_ids} =
        Object.query(
          {:or,
           [
             {:attribute, {BasicComponent, attribute_key}},
             {:component, BasicComponent},
             {:command_set, BasicCommandSet},
             {:or,
              [
                {:link, link_type},
                {:link, {link_type, {:to, object_id2}}},
                {:link, {link_type, {:from, object_id2}, "foo"}},
                {:tag, {tag_category, tag}}
              ]}
           ]}
        )

      assert object_id in object_ids
    end
  end

  defp create_new_object(_context) do
    object_id = Object.new!()
    %{object_id: object_id}
  end
end
