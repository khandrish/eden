defmodule Exmud.Engine.Test.ComponentTest do
  alias Ecto.UUID
  alias Exmud.Engine.Attribute
  alias Exmud.Engine.Component
  alias Exmud.Engine.ComponentTest.BadExampleComponent, as: BEC
  alias Exmud.Engine.ComponentTest.ExampleComponent, as: EC
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
      assert Component.add(object_id, component) == {:error, :component_population_failed}
      assert Component.register(component, EC) == {:ok, :registered}
      assert Component.register(component2, EC) == {:ok, :registered}
      assert Component.register(component3, BEC) == {:ok, :registered}
      assert Component.add(object_id, component) == {:ok, object_id}
      assert Component.add(object_id, component2) == {:ok, object_id}
      assert Component.add(object_id, component3) == {:error, :component_population_failed}
      assert Component.has(object_id, component) == {:ok, true}
      assert Component.has_any(object_id, component) == {:ok, true}
      {:ok, result} = Component.get(object_id, component)
      assert result.component == component
      assert Component.remove(object_id, component) == {:ok, true}
      assert Component.has(object_id, component) == {:ok, false}
      assert Component.remove(object_id) == {:ok, true}
      assert Component.has(object_id, component2) == {:ok, false}
    end

    @tag component: true
    @tag engine: true
    test "engine registration" do
      key = UUID.generate()
      callback_module = UUID.generate()
      assert Component.register(key, callback_module) == {:ok, :registered}
      assert Component.registered?(key) == {:ok, true}
      assert Enum.any?(Component.list_registered(), fn(k) -> key == k end) == true
      assert Component.lookup(callback_module) == {:error, :no_such_component}
      {:ok, callback} = Component.lookup(key)
      assert callback == callback_module
      assert Component.unregister(key) == {:ok, true}
      assert Component.registered?(key) == {:ok, false}
      assert Enum.any?(Component.list_registered(), fn(k) -> key == k end) == false
    end

    @tag component: true
    @tag engine: true
    test "get tests", %{object_id: object_id} = _context do
      component = UUID.generate()
      assert Component.register(component, Exmud.Engine.ComponentTest.ExampleComponent) == {:ok, :registered}
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

defmodule Exmud.Engine.ComponentTest.ExampleComponent do
  def populate do
    {:ok, :populated}
  end
end

defmodule Exmud.Engine.ComponentTest.BadExampleComponent do
  def populate do
    {:error, :fubar}
  end
end