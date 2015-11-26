defmodule Eden.EntityManagerTest do
  use Eden.Case
  use Eden.EntityCase

  setup do
    {:ok, %{:entity => create_entity}}
  end

  test "Load all entities from db" do
    assert :ok = EM.load_all_entities
  end

  test "Entity Lifecycle" do
    id = create_entity
    assert :false == EM.has_key?(id, "foo", "foo")
    assert :false == EM.set(id, "foo", "foo", "bar")
    assert :false == EM.has_component?(id, "foo")
    assert :true == EM.add_component(id, "foo")
    assert ["foo"] == EM.get_all_components(id)
    assert :true == EM.has_component?(id, "foo")
    assert :true == EM.set(id, "foo", "foo", "bar")
    assert :true == EM.has_key?(id, "foo", "foo")
    assert :true == EM.delete(id, "foo", "foo")
    assert :false == EM.has_key?(id, "foo", "foo")
    assert :true == EM.set(id, "foo", "foo", "bar")
    assert "bar" == EM.get(id, "foo", "foo")
    assert :true == EM.persist_entity(id)
    assert :true == EM.remove_component(id, "foo")
    assert [] == EM.get_all_components(id)
    assert :false == EM.has_component?(id, "foo")
    assert :false == EM.has_key?(id, "foo", "foo")
  end
end
