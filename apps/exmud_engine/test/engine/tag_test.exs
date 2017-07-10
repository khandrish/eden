defmodule Exmud.Engine.Test.TagTest do
  alias Ecto.UUID
  alias Exmud.Engine.Object
  alias Exmud.Engine.Tag
  require Logger
  use Exmud.Engine.Test.DBTestCase

  describe "Multi Ecto usage tests for tags:" do
    setup [:create_new_object_multi]

    @tag tag: true
    @tag object: true
    test "lifecycle", %{multi: multi, object_id: object_id} = _context do
      assert Repo.transaction(Tag.has(multi, "has tag", object_id, "foo", "bar")) == {:ok, %{"has tag" => false}}
      assert Repo.transaction(Tag.add(multi, "add tag", object_id, "foo", "bar")) == {:ok, %{"add tag" => object_id}}
      assert Repo.transaction(Tag.has(multi, "has tag", object_id, "foo", "bar")) == {:ok, %{"has tag" => true}}
      assert Repo.transaction(Tag.remove(multi, "remove tag", object_id, "foo", "bar")) == {:ok, %{"remove tag" => object_id}}
      assert Repo.transaction(Tag.has(multi, "has tag", object_id, "foo", "bar")) == {:ok, %{"has tag" => false}}
    end

    @tag tag: true
    @tag object: true
    test "invalid cases", %{multi: multi} = _context do
      assert Repo.transaction(Tag.add(multi, "add tag", "invalid id", :invalid_tag, "bar")) ==
        {:error, "add tag", :no_such_object, %{}}
      assert Repo.transaction(Tag.has(multi, "has tag", 0, "foo", "bar")) == {:ok, %{"has tag" => false}}
      assert Repo.transaction(Tag.remove(multi, "remove tag", 0, "foo", "bar")) == {:error, "remove tag", :no_such_tag, %{}}
    end
  end

  defp create_new_object_multi(_context) do
    tag = UUID.generate()
    {:ok, results} = Ecto.Multi.new()
    |> Object.new("new_object", tag)
    |> Repo.transaction()

    %{tag: tag, multi: Ecto.Multi.new(), object_id: results["new_object"]}
  end
end