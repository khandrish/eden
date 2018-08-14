defmodule Exmud.Engine.Test.AttributeTest do
  alias Ecto.UUID
  alias Exmud.Engine.Attribute
  alias Exmud.Engine.Component
  alias Exmud.Engine.Object
  require Logger
  use Exmud.Engine.Test.DBTestCase

  # Test Components
  alias Exmud.Engine.Test.Component.Basic

  describe "Usage tests for attributes:" do
    setup [:create_new_object]

    @tag attribute: true
    @tag engine: true
    test "lifecycle", %{object_id: object_id} = _context do
      attribute = UUID.generate()
      attribute2 = UUID.generate()
      assert Component.attach(object_id, Basic) == :ok
      assert Attribute.equals?(object_id, Basic, attribute, "bar") == false
      assert Attribute.put(object_id, Basic, attribute, "bar") == :ok
      assert Attribute.equals?(object_id, Basic, attribute, "bar") == true
      assert Attribute.equals?(object_id, Basic, attribute, &(&1 == "bar")) == true
      assert Attribute.put(object_id, Basic, attribute2, "bar") == :ok
      assert Attribute.read(object_id, Basic, attribute) == {:ok, "bar"}
      assert Attribute.update(object_id, Basic, attribute, "foobar") == :ok
      assert Attribute.read(object_id, Basic, attribute) == {:ok, "foobar"}
      assert Attribute.exists?(object_id, Basic, attribute) == true
      assert Attribute.delete(object_id, Basic, attribute) == :ok
      assert Attribute.read(object_id, Basic, attribute) == {:error, :no_such_attribute}
      assert Attribute.exists?(object_id, Basic, attribute) == false
    end

    @tag attribute: true
    @tag engine: true
    test "invalid cases", %{object_id: object_id} = _context do
      component = UUID.generate()
      assert Component.attach( object_id, Basic ) == :ok
      assert Attribute.read(object_id, component, "foo") == {:error, :no_such_attribute}
      assert Attribute.put(object_id, component, "foo", "bar") == {:error, :no_such_component}
      assert Attribute.exists?(object_id, Basic, "foo") == false
      assert Attribute.delete(object_id, Basic, "foo") == {:error, :no_such_attribute}
      assert Attribute.read(object_id, Basic, "foo") == {:error, :no_such_attribute}
    end
  end

  defp create_new_object(_context) do
    object_id = Object.new!()

    %{object_id: object_id}
  end
end
