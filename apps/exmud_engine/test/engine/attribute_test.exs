defmodule Exmud.Engine.Test.AttributeTest do
  alias Ecto.UUID
  alias Exmud.Engine.Attribute
  alias Exmud.Engine.Component
  alias Exmud.Engine.Object
  require Logger
  use Exmud.Engine.Test.DBTestCase

  # Test Components
  alias Exmud.Engine.Test.Component.Bad
  alias Exmud.Engine.Test.Component.Basic

  describe "Usage tests for attributes:" do
    setup [:create_new_object, :register_test_components]

    @tag attribute: true
    @tag engine: true
    test "lifecycle", %{object_id: object_id} = _context do
      attribute = UUID.generate()
      attribute2 = UUID.generate()
      assert Component.register(Basic) == :ok
      assert Component.attach(object_id, Basic.name()) == :ok
      assert Attribute.equals?(object_id, Basic.name(), attribute, "bar") == false
      assert Attribute.put(object_id, Basic.name(), attribute, "bar") == :ok
      assert Attribute.equals?(object_id, Basic.name(), attribute, "bar") == true
      assert Attribute.put(object_id, Basic.name(), attribute2, "bar") == :ok
      assert Attribute.read(object_id, Basic.name(), attribute) == {:ok, "bar"}
      assert Attribute.update(object_id, Basic.name(), attribute, "foobar") == :ok
      assert Attribute.read(object_id, Basic.name(), attribute) == {:ok, "foobar"}
      assert Attribute.exists?(object_id, Basic.name(), attribute) == true
      assert Attribute.delete(object_id, Basic.name(), attribute) == :ok
      assert Attribute.read(object_id, Basic.name(), attribute) == {:error, :no_such_attribute}
      assert Attribute.exists?(object_id, Basic.name(), attribute) == false
    end

    @tag attribute: true
    @tag engine: true
    test "invalid cases", %{object_id: object_id} = _context do
      component = UUID.generate()
      component2 = UUID.generate()
      assert Component.register(Basic) == :ok
      assert Component.register(Bad) == :ok
      assert Component.attach(object_id, Basic.name()) == :ok
      assert Attribute.read(object_id, component2, "foo") == {:error, :no_such_attribute}
      assert Attribute.put(object_id, component2, "foo", "bar") == {:error, :no_such_component}
      assert Attribute.exists?(object_id, Basic.name(), "foo") == false
      assert Attribute.delete(object_id, Basic.name(), "foo") == {:error, :no_such_attribute}
      assert Attribute.read(object_id, Basic.name(), "foo") == {:error, :no_such_attribute}
    end
  end

  defp create_new_object(_context) do
    key = UUID.generate()
    {:ok, object_id} = Object.new(key)

    %{key: key, object_id: object_id}
  end

  @components [Basic, Bad]

  defp register_test_components(context) do
    Enum.each(@components, &Component.register/1)

    context
  end
end


defmodule Exmud.Engine.AttributeTest.ExampleComponent do
  def populate do
    {:ok, :populated}
  end
end