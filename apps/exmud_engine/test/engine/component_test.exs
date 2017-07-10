defmodule Exmud.Engine.Test.ComponentTest do
  alias Ecto.UUID
  alias Exmud.Engine.Component
  alias Exmud.Engine.Object
  alias Exmud.Engine.Repo
  require Logger
  use Exmud.Engine.Test.DBTestCase

  describe "Multi Ecto usage tests for components: " do
    setup [:create_new_object_multi]

    @tag component: true
    @tag engine: true
    test "component tests", %{multi: multi, object_id: object_id} = _context do
      component = UUID.generate()
      assert Repo.transaction(Component.add(multi, "add component", object_id, component)) == {:ok, %{"add component" => object_id}}
      assert Repo.transaction(Component.has(multi, "has component", object_id, component)) == {:ok, %{"has component" => true}}
      assert Repo.transaction(Component.has_any(multi, "has_any component", object_id, component)) == {:ok, %{"has_any component" => true}}
      {:ok, %{"get component" => result}} = Repo.transaction(Component.get(multi, "get component", object_id, component))
      assert result.component == component
      assert Repo.transaction(Component.remove(multi, "remove component", object_id, component)) == {:ok, %{"remove component" => true}}
      assert Repo.transaction(Component.has(multi, "has component", object_id, component)) == {:ok, %{"has component" => false}}
    end
  end

  defp create_new_object_multi(_context) do
    key = UUID.generate()
    {:ok, results} = Ecto.Multi.new()
    |> Object.new("new_object", key)
    |> Repo.transaction()

    %{key: key, multi: Ecto.Multi.new(), object_id: results["new_object"]}
  end
end