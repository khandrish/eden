defmodule Exmud.Engine.Test.ComponentTest do
  alias Ecto.UUID
  alias Exmud.Engine.Attribute
  alias Exmud.Engine.Component
  alias Exmud.Engine.Object
  alias Exmud.Engine.Repo
  require Logger
  use Exmud.Engine.Test.DBTestCase

  describe "Usage tests for components: " do
    setup [:create_new_object]

    @tag component: true
    @tag engine: true
    test "lifecycle", %{object_id: object_id} = _context do
      component = UUID.generate()
      component2 = UUID.generate()
      component3 = UUID.generate()
      assert Component.add(object_id, component) == {:ok, object_id}
      assert Component.add(object_id, component2) == {:ok, object_id}
      assert Component.add(object_id, component3) == {:ok, object_id}
      assert Component.has(object_id, component) == {:ok, true}
      assert Component.has_any(object_id, component) == {:ok, true}
      {:ok, result} = Component.get(object_id, component)
      assert result.component == component
      assert Component.remove(object_id, component) == {:ok, true}
      assert Component.has(object_id, component) == {:ok, false}
      assert Component.remove(object_id) == {:ok, true}
      assert Component.has(object_id, component2) == {:ok, false}
      assert Component.has(object_id, component3) == {:ok, false}
    end

    @tag component: true
    @tag engine: true
    test "get tests", %{object_id: object_id} = _context do
      component = UUID.generate()
      attribute_key = UUID.generate()
      attribute_data = UUID.generate()
      assert Component.add(object_id, component) == {:ok, object_id}
      assert Attribute.add(object_id, component, attribute_key, attribute_data) == {:ok, object_id}
      {:ok, comp} = Component.get(object_id)
      {:ok, comp2} = Component.get(component)
      assert comp == comp2
    end
  end

  defp create_new_object(_context) do
    key = UUID.generate()
    {:ok, object_id} = Object.new(key)

    %{key: key, object_id: object_id}
  end
end