defmodule Eden.EntityManagerTest do
  use Eden.Case
  use Eden.EntityCase

  setup do
    {:ok, %{:entity => create_entity}}
  end

  test "Load all entities from db" do
    assert :ok = EM.load_all_entities
  end

  test "Entity does not have key", %{entity: id} do
    assert :false == EM.has_key?(id, "foo", "foo")
  end

  test "Entity has key after setting", %{entity: id} do
    assert :true == EM.add_component(id, "foo")
    assert :true == EM.put_key(id, "foo", "foo", "bar")
    assert :false == EM.has_key?(id, "foo", "baz")
    assert :true == EM.has_key?(id, "foo", "foo")
  end

  test "Entity does not have component", %{entity: id} do
    assert :false == EM.has_component?(id, "foo")
  end

  test "Entity has component after adding", %{entity: id} do
    assert :false == EM.has_component?(id, "foo")
    assert :true == EM.add_component(id, "foo")
    assert :false == EM.has_component?(id, "bar")
    assert :true == EM.has_component?(id, "foo")
    assert ["foo"] == EM.get_all_components(id)
  end

  test "Can remove component from entity", %{entity: id} do
    assert :true == EM.add_component(id, "foo")
    assert :true == EM.remove_component(id, "foo")
    assert :false == EM.has_component?(id, "foo")
  end

  test "Can delete key from entity", %{entity: id} do
    assert :true == EM.add_component(id, "foo")
    assert :true == EM.put_key(id, "foo", "foo", "bar")
    assert :true == EM.has_key?(id, "foo", "foo")
    assert :true == EM.delete_key(id, "foo", "foo")
    assert :false == EM.has_key?(id, "foo", "foo")
  end

  test "Can persist entity", %{entity: id} do
    assert :true == EM.add_component(id, "foo")
    assert :true == EM.put_key(id, "foo", "foo", "bar")
    assert :true == EM.persist_entity(id)
    assert :true == EM.delete_entity_from_cache(id)
    assert :true == EM.load_entity(id)
    assert "bar" == EM.get_key(id, "foo", "foo")
  end
end
