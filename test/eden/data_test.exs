defmodule DataTest do
  alias Eden.Data
  use Amnesia
  use ExUnit.Case

  setup do
    %{entity: Amnesia.transaction(fn -> Data.new_entity end)}
  end

  test "get_entity/1 single component success case", %{entity: entity} = _context do
    refute Amnesia.transaction(fn -> Data.get_entity(entity.id) end) == nil
  end

  test "get_entity/1 multiple component success case", %{entity: entity} = _context do
    Amnesia.transaction do
      Data.add_component(entity.id, "test", %{})
    end

    refute Amnesia.transaction(fn -> Data.get_entity(entity.id) end) == nil
  end

  test "get_entity/1 failure case" do
    assert Amnesia.transaction(fn -> Data.get_entity("foo") end) == nil
  end

  test "get_entities_with_component/1 success case" do
    refute Amnesia.transaction(fn -> Data.get_entities_with_component("entity") end) == []
  end

  test "get_entities_with_component/1 failure case" do
    assert Amnesia.transaction(fn -> Data.get_entities_with_component("foo") end) == []
  end

  test "get_entities_with_components/1 success case", %{entity: entity} = _context do
    Amnesia.transaction do
      Data.add_component(entity.id, "test", %{})
    end

    refute Amnesia.transaction(fn -> Data.get_entities_with_components(["entity", "test"]) end) == []
  end
end