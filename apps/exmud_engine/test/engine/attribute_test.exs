defmodule Exmud.Engine.Test.AttributeTest do
  alias Ecto.UUID
  alias Exmud.Engine.Attribute
  alias Exmud.Engine.Component
  alias Exmud.Engine.Object
  require Logger
  use Exmud.Engine.Test.DBTestCase

  describe "Multi Ecto usage tests for game object: " do
    setup [:create_new_object_multi]

    @tag attribute: true
    @tag object: true
    test "attribute lifecycle", %{multi: multi, oid: oid} = _context do
      component = UUID.generate()
      attribute = UUID.generate()
      attribute2 = UUID.generate()
      assert Repo.transaction(Component.add(multi, "add component", oid, component)) == {:ok, %{"add component" => oid}}
      assert Repo.transaction(Attribute.equals(multi, "attribute equals", oid, component, attribute, "bar")) == {:ok, %{"attribute equals" => false}}
      assert Repo.transaction(Attribute.add(multi, "add attribute", oid, component, attribute, "bar")) == {:ok, %{"add attribute" => oid}}
      assert Repo.transaction(Attribute.equals(multi, "attribute equals", oid, component, attribute, "bar")) == {:ok, %{"attribute equals" => true}}
      assert Repo.transaction(Attribute.add(multi, "add attribute", oid, component, attribute2, "bar")) == {:ok, %{"add attribute" => oid}}
      assert Repo.transaction(Attribute.get(multi, "get attribute", oid, component, attribute)) == {:ok, %{"get attribute" => "bar"}}
      assert Repo.transaction(Attribute.update(multi, "update attribute", oid, component, attribute, "foobar")) == {:ok, %{"update attribute" => oid}}
      assert Repo.transaction(Attribute.get(multi, "get attribute", oid, component, attribute)) == {:ok, %{"get attribute" => "foobar"}}
      assert Repo.transaction(Attribute.has(multi, "has attribute", oid, component, attribute)) == {:ok, %{"has attribute" => true}}
      assert Repo.transaction(Attribute.remove(multi, "remove attribute", oid, component, attribute)) == {:ok, %{"remove attribute" => oid}}
      assert Repo.transaction(Attribute.get(multi, "get attribute", oid, component, attribute)) == {:error, "get attribute", :no_such_attribute, %{}}
      assert Repo.transaction(Attribute.has(multi, "has attribute", oid, component, attribute)) == {:ok, %{"has attribute" => false}}
    end

    @tag attribute: true
    @tag object: true
    test "attribute invalid cases", %{multi: multi, oid: oid} = _context do
      component = UUID.generate()
      assert Repo.transaction(Component.add(multi, "add component", oid, component)) == {:ok, %{"add component" => oid}}
      assert Repo.transaction(Attribute.get(multi, "get attribute", oid, component, "foo")) == {:error, "get attribute", :no_such_attribute, %{}}
      assert Repo.transaction(Attribute.add(multi, "add attribute", 0, component, "foo", "bar")) == {:error, "add attribute", :no_such_component, %{}}
      assert Repo.transaction(Attribute.has(multi, "has attribute", 0, component, "foo")) == {:ok, %{"has attribute" => false}}
      assert Repo.transaction(Attribute.remove(multi, "remove attribute", 0, component, "foo")) == {:error, "remove attribute", :no_such_attribute, %{}}
      assert Repo.transaction(Attribute.get(multi, "get attribute", 0, component, "foo")) == {:error, "get attribute", :no_such_attribute, %{}}
    end
  end

  defp create_new_object_multi(_context) do
    key = UUID.generate()
    {:ok, results} = Ecto.Multi.new()
    |> Object.new("new_object", key)
    |> Repo.transaction()

    %{key: key, multi: Ecto.Multi.new(), oid: results["new_object"]}
  end
end