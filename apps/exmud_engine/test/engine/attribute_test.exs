defmodule Exmud.Engine.Test.AttributeTest do
  alias Ecto.UUID
  alias Exmud.Engine.Attribute
  alias Exmud.Engine.Component
  alias Exmud.Engine.Object
  require Logger
  use Exmud.Engine.Test.DBTestCase

  describe "Usage tests for attributes:" do
    setup [:create_new_object]

    @tag attribute: true
    @tag engine: true
    test "lifecycle", %{object_id: object_id} = _context do
      component = UUID.generate()
      attribute = UUID.generate()
      attribute2 = UUID.generate()
      assert Component.add(object_id, component) == {:ok, object_id}
      assert Attribute.equals(object_id, component, attribute, "bar") == {:ok, false}
      assert Attribute.add(object_id, component, attribute, "bar") == {:ok, object_id}
      assert Attribute.equals(object_id, component, attribute, "bar") == {:ok, true}
      assert Attribute.add(object_id, component, attribute2, "bar") == {:ok, object_id}
      assert Attribute.get(object_id, component, attribute) == {:ok, "bar"}
      assert Attribute.update(object_id, component, attribute, "foobar") == {:ok, object_id}
      assert Attribute.get(object_id, component, attribute) == {:ok, "foobar"}
      assert Attribute.has(object_id, component, attribute) == {:ok, true}
      assert Attribute.remove(object_id, component, attribute) == {:ok, object_id}
      assert Attribute.get(object_id, component, attribute) == {:error, :no_such_attribute}
      assert Attribute.has(object_id, component, attribute) == {:ok, false}
    end

    @tag attribute: true
    @tag engine: true
    test "invalid cases", %{object_id: object_id} = _context do
      component = UUID.generate()
      component2 = UUID.generate()
      assert Component.add(object_id, component) == {:ok, object_id}
      assert Attribute.get(object_id, component, "foo") == {:error, :no_such_attribute}
      assert Attribute.add(object_id, component2, "foo", "bar") == {:error, :no_such_component}
      assert Attribute.has(object_id, component, "foo") == {:ok, false}
      assert Attribute.remove(object_id, component, "foo") == {:error, :no_such_attribute}
      assert Attribute.get(object_id, component, "foo") == {:error, :no_such_attribute}
    end
  end

  defp create_new_object(_context) do
    key = UUID.generate()
    {:ok, object_id} = Object.new(key)

    %{key: key, object_id: object_id}
  end
end