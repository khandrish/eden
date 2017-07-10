defmodule Exmud.Engine.Test.CommandSetTest do
  alias Ecto.UUID
  alias Exmud.Engine.CommandSet
  alias Exmud.Engine.Object
  alias Exmud.Engine.Repo
  require Logger
  use Exmud.Engine.Test.DBTestCase

  describe "Multi Ecto usage tests for command sets: " do
    setup [:create_new_object_multi]

    @tag command_set: true
    @tag engine: true
    test "command set tests", %{multi: multi, object_id: object_id} = _context do
      callback_module = UUID.generate()
      assert Repo.transaction(CommandSet.add(multi, "add command_set", object_id, callback_module)) == {:ok, %{"add command_set" => object_id}}
      assert Repo.transaction(CommandSet.has(multi, "has command_set", object_id, callback_module)) == {:ok, %{"has command_set" => true}}
      assert Repo.transaction(CommandSet.remove(multi, "remove command_set", object_id, callback_module)) == {:ok, %{"remove command_set" => true}}
      assert Repo.transaction(CommandSet.has(multi, "has command_set", object_id, callback_module)) == {:ok, %{"has command_set" => false}}
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