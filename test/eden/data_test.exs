defmodule DataTest do
  alias Eden.Data
  alias Eden.Entity
  use Amnesia
  use ExUnit.Case

  setup do
    %{entity: Amnesia.transaction(fn -> Entity.new end)}
  end

  test "has_component/2 success case", %{entity: entity} = _context do
    assert Amnesia.transaction(fn -> Entity.has_component?(entity, "entity") end) == true
  end

  test "has_component/2 failure case", %{entity: entity} = _context do
    assert Amnesia.transaction(fn -> Entity.has_component?(entity, "foo") end) == false
  end

  test "add_component/2", %{entity: entity} = _context do
    Amnesia.transaction do
      Entity.add_component(entity, "test")
    end

    assert Amnesia.transaction(fn -> Entity.has_component?(entity, "test") end) == true
  end

  test "remove_component/2", %{entity: entity} = _context do
    Amnesia.transaction do
      Entity.add_component(entity, "test")
      Entity.remove_component(entity, "test")
    end

    assert Amnesia.transaction(fn -> Entity.has_component?(entity, "test") end) == false
  end

  test "get_key/3 success case", %{entity: entity} = _context do
    refute Amnesia.transaction(fn -> Entity.get_key(entity, "entity", "created") end) == nil
  end

  test "get_key/3 failure case", %{entity: entity} = _context do
    assert Amnesia.transaction(fn -> Entity.get_key(entity, "entity", "foo") end) == nil
  end

  test "has_key/3 success case", %{entity: entity} = _context do
    assert Amnesia.transaction(fn -> Entity.has_key?(entity, "entity", "created") end) == true
  end

  test "has_key/3 failure case", %{entity: entity} = _context do
    assert Amnesia.transaction(fn -> Entity.has_key?(entity, "entity", "foo") end) == false
    assert Amnesia.transaction(fn -> Entity.has_key?(entity, "foo", "created") end) == false
    assert Amnesia.transaction(fn -> Entity.has_key?("foo", "entity", "created") end) == false
  end

  test "add_key/3", %{entity: entity} = _context do
    Amnesia.transaction do
      Entity.add_component(entity, "test")
      Entity.add_key(entity, "test", "foo", "bar")
    end

    assert Amnesia.transaction(fn -> Entity.has_key?(entity, "test", "foo") end) == true
  end

  test "get_all_keys/2 results case", %{entity: entity} = _context do
    refute Amnesia.transaction(fn -> Entity.get_all_keys("entity", "created") end) == []
  end

  test "remove_key/3", %{entity: entity} = _context do
    Amnesia.transaction do
      Entity.add_component(entity, "test")
      Entity.add_key(entity, "test", "foo", "bar")
      Entity.remove_key(entity, "test", "foo")
    end

    assert Amnesia.transaction(fn -> Entity.has_key?(entity, "test", "foo") end) == false
  end
end