defmodule DataTest do
  alias Eden.Db
  alias Eden.Entity
  use ExUnit.Case

  setup do
    %{entity: Db.transaction(fn -> Entity.new end)}
  end

  test "get/1", %{entity: entity} = _context do
    entities = Db.transaction(fn ->
      Enum.map(1..5, fn(_) -> Entity.new() end)
    end)

    refute Db.transaction(fn -> Entity.get(entity) end) == nil
    assert Db.transaction(fn -> Entity.get(0) end) == nil
    assert Db.transaction(fn -> Entity.get([0, 0, 0, 0, 0]) end) == []
    assert length(Db.transaction(fn -> Entity.get(entities) end)) == 5
  end

  test "has_component/2", %{entity: entity} = _context do
    assert Db.transaction(fn -> Entity.has_component?(entity, "entity") end) == true
    assert Db.transaction(fn -> Entity.has_component?(entity, "foo") end) == false
  end

  test "add_component/2", %{entity: entity} = _context do
    Db.transaction(fn ->
      Entity.add_component(entity, "test")
    end)

    assert Db.transaction(fn -> Entity.has_component?(entity, "test") end) == true
  end

  test "remove_component/2", %{entity: entity} = _context do
    Db.transaction(fn ->
      Entity.add_component(entity, "test")
      Entity.remove_component(entity, "test")
    end)

    assert Db.transaction(fn -> Entity.has_component?(entity, "test") end) == false
  end

  test "list_with_components/1", %{entity: entity} = _context do
    Db.transaction(fn ->
      Entity.add_component(entity, "test")
    end)

    refute Db.transaction(fn -> Entity.list_with_components("entity") end) == []
    refute Db.transaction(fn -> Entity.list_with_components(["entity", "test"]) end) == []
  end


  test "get_key/3 success case", %{entity: entity} = _context do
    refute Db.transaction(fn -> Entity.get_key(entity, "entity", "created") end) == nil
    assert Db.transaction(fn -> Entity.get_key(entity, "entity", "foo") end) == nil
  end

  test "has_key/3 success case", %{entity: entity} = _context do
    assert Db.transaction(fn -> Entity.has_key?(entity, "entity", "created") end) == true
    assert Db.transaction(fn -> Entity.has_key?(entity, "entity", "foo") end) == false
    assert Db.transaction(fn -> Entity.has_key?(entity, "foo", "created") end) == false
    assert Db.transaction(fn -> Entity.has_key?("foo", "entity", "created") end) == false
  end

  test "add_key/3", %{entity: entity} = _context do
    Db.transaction(fn ->
      Entity.add_component(entity, "test")
      Entity.add_key(entity, "test", "foo", "bar")
    end)

    assert Db.transaction(fn -> Entity.has_key?(entity, "test", "foo") end) == true
  end

  test "put_key/3", %{entity: entity} = _context do
    assert Db.transaction(fn -> Entity.put_key(entity, "test", "foo") end) == true
    assert Db.transaction(fn -> Entity.has_component?(entity, "test") end) == true
  end

  test "get_all_keys/2 results case", %{entity: _entity} = _context do
    refute Db.transaction(fn -> Entity.get_all_keys("entity", "created") end) == []
  end

  test "remove_key/3", %{entity: entity} = _context do
    Db.transaction(fn ->
      Entity.add_key(entity, "test", "foo", "bar")
      Entity.remove_key(entity, "test", "foo")
    end)

    assert Db.transaction(fn -> Entity.has_key?(entity, "test", "foo") end) == false
  end
end