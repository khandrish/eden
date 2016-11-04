defmodule Exmud.EntityTest do
#   alias Eden.Entity
#   alias Eden.TestComponent, as: TC
#   use ExUnit.Case

#   setup do
#     %{entity: Entity.transaction(fn -> Entity.new end)}
#   end

#   test "add_component/2", %{entity: entity} = _context do
#     Entity.transaction(fn ->
#       Entity.add_component(entity, TC)
#     end)

#     assert Entity.transaction(fn -> Entity.has_component?(entity, TC) end) == true
#   end

#   test "add_key/3", %{entity: entity} = _context do
#     Entity.transaction(fn ->
#       Entity.add_component(entity, TC)
#       Entity.add_key(entity, TC, "foo", "bar")
#     end)

#     assert Entity.transaction(fn -> Entity.has_key?(entity, TC, "foo") end) == true
#   end

#   test "delete/1", %{entity: entity} = _context do
#     assert Entity.transaction(fn -> Entity.delete(entity) end) == true
#     assert Entity.transaction(fn -> Entity.get(entity) end) == nil
#   end

#   test "get/1", %{entity: entity} = _context do
#     entities = Entity.transaction(fn ->
#       Enum.map(1..5, fn(_) -> Entity.new() end)
#     end)

#     refute Entity.transaction(fn -> Entity.get(entity) end) == nil
#     assert Entity.transaction(fn -> Entity.get(0) end) == nil
#     assert Entity.transaction(fn -> Entity.get([0, 0, 0, 0, 0]) end) == []
#     assert length(Entity.transaction(fn -> Entity.get(entities) end)) == 5
#   end

#   test "get_all_keys/2", %{entity: _entity} = _context do
#     refute Entity.transaction(fn -> Entity.get_all_keys("entity", "created") end) == []
#   end


#   test "get_key/3", %{entity: entity} = _context do
#     refute Entity.transaction(fn -> Entity.get_key(entity, "entity", "created") end) == nil
#     assert Entity.transaction(fn -> Entity.get_key(entity, "entity", "foo") end) == nil
#   end

#   test "has_component/2", %{entity: entity} = _context do
#     assert Entity.transaction(fn -> Entity.has_component?(entity, "entity") end) == true
#     assert Entity.transaction(fn -> Entity.has_component?(entity, "foo") end) == false
#   end

#   test "has_key/3", %{entity: entity} = _context do
#     assert Entity.transaction(fn -> Entity.has_key?(entity, "entity", "created") end) == true
#     assert Entity.transaction(fn -> Entity.has_key?(entity, "entity", "foo") end) == false
#     assert Entity.transaction(fn -> Entity.has_key?(entity, "foo", "created") end) == false
#     assert Entity.transaction(fn -> Entity.has_key?("foo", "entity", "created") end) == false
#   end

#   test "list_components/1", %{entity: entity} = _context do
#     Entity.transaction(fn ->
#       Entity.add_component(entity, TC)
#     end)

#     assert length(Entity.transaction(fn -> Entity.list_components(entity) end)) == 2
#   end

#   test "list_with_components/1", %{entity: entity} = _context do
#     Entity.transaction(fn ->
#       Entity.add_component(entity, TC)
#     end)

#     refute Entity.transaction(fn -> Entity.list_with_components("entity") end) == []
#     refute Entity.transaction(fn -> Entity.list_with_components(["entity", TC]) end) == []
#   end

#   test "put_key/3", %{entity: entity} = _context do
#     assert is_integer(Entity.transaction(fn -> Entity.put_key(entity, TC, "foo") end)) == true
#     assert Entity.transaction(fn -> Entity.has_component?(entity, TC) end) == true
#   end

#   test "remove_component/2", %{entity: entity} = _context do
#     Entity.transaction(fn ->
#       Entity.add_component(entity, TC)
#       Entity.remove_component(entity, TC)
#     end)

#     assert Entity.transaction(fn -> Entity.has_component?(entity, TC) end) == false
#   end

#   test "remove_key/3", %{entity: entity} = _context do
#     Entity.transaction(fn ->
#       Entity.add_key(entity, TC, "foo", "bar")
#       assert Entity.has_key?(entity, TC, "foo") == true
#       Entity.remove_key(entity, TC, "foo")
#       assert Entity.has_key?(entity, TC, "foo") == false
#     end)
#   end

#   test "value_exists?/3", %{entity: entity} = _context do
#     Entity.transaction(fn ->
#       Entity.add_key(entity, TC, "foo", "bar")
#     end)

#     assert Entity.transaction(fn -> Entity.value_exists?(TC, "foo", "bar") end) == true
#     assert Entity.transaction(fn -> Entity.value_exists?(TC, "foo", "barbarblacksheep") end) == false
#   end
# end

# defmodule Eden.TestComponent do
#   def init(_) do
#     :ok
#   end

#   def destroy(_) do
#     :ok
#   end
end
