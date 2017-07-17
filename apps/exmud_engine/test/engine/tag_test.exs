defmodule Exmud.Engine.Test.TagTest do
  alias Ecto.UUID
  alias Exmud.Engine.Object
  alias Exmud.Engine.Tag
  require Logger
  use Exmud.Engine.Test.DBTestCase

  describe "Multi Ecto usage tests for tags:" do
    setup [:create_new_object]

    @tag tag: true
    @tag engine: true
    test "lifecycle", %{object_id: object_id} = _context do
      assert Tag.has(object_id, "foo", "bar") == {:ok, false}
      assert Tag.add(object_id, "foo", "bar") == {:ok, object_id}
      assert Tag.has(object_id, "foo", "bar") == {:ok, true}
      assert Tag.remove(object_id, "foo", "bar") == {:ok, object_id}
      assert Tag.has(object_id, "foo", "bar") == {:ok, false}
    end

    @tag tag: true
    @tag engine: true
    test "invalid cases" do
      assert Tag.add("invalid id", :invalid_tag, "bar") == {:error, :no_such_object}
      assert Tag.has(0, "foo", "bar") == {:ok, false}
      assert Tag.remove(0, "foo", "bar") == {:error, :no_such_tag}
    end
  end

  defp create_new_object(_context) do
    key = UUID.generate()
    {:ok, object_id} = Object.new(key)

    %{key: key, object_id: object_id}
  end
end