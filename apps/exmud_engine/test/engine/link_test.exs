defmodule Exmud.Engine.Test.LinkTest do
  alias Ecto.UUID
  alias Exmud.Engine.Link
  alias Exmud.Engine.Object
  require Logger
  use Exmud.Engine.Test.DBTestCase

  describe "Unlinked tests:" do
    setup [:create_new_objects, :generate_link_type, :generate_data]

    @tag link: true
    @tag engine: true
    test "forge link with no data", %{object_id1: object_id1, object_id2: object_id2, type: link_type} = _context do
      assert Link.forge(object_id1, object_id2, link_type) == :ok
      assert Link.linked?(object_id1, object_id2) == true
      assert Link.linked?(object_id1, object_id2, link_type) == true
      assert Link.linked?(object_id1, object_id2, link_type, nil) == true
      assert Link.linked?(object_id1, object_id2, link_type, nil, &(&1 == &2)) == true
    end

    @tag link: true
    @tag engine: true
    test "forge link with data", %{object_id1: object_id1, object_id2: object_id2, type: link_type, data: data} = _context do
      assert Link.forge(object_id1, object_id2, link_type, data) == :ok
      assert Link.linked?(object_id1, object_id2) == true
      assert Link.linked?(object_id1, object_id2, link_type) == true
      assert Link.linked?(object_id1, object_id2, link_type, data) == true
      assert Link.linked?(object_id1, object_id2, link_type, data, &(&1 == &2)) == true
    end
  end

  describe "Linked tests:" do
    setup [:create_new_objects, :generate_link_type, :generate_data, :forge_link]

    @tag link: true
    @tag engine: true
    test "break all links on a single object", %{object_id1: object_id1, object_id2: object_id2, type: link_type, data: data} = _context do
      assert Link.linked?(object_id1, object_id2) == true
      assert Link.linked?(object_id1, object_id2, link_type) == true
      assert Link.linked?(object_id1, object_id2, link_type, data) == true
      assert Link.linked?(object_id1, object_id2, link_type, data, &(&1 == &2)) == true
      assert Link.break_all(object_id1) == :ok
      assert Link.linked?(object_id1, object_id2) == false
      assert Link.linked?(object_id1, object_id2, link_type) == false
      assert Link.linked?(object_id1, object_id2, link_type, data) == false
      assert Link.linked?(object_id1, object_id2, link_type, data, &(&1 == &2)) == false
    end

    @tag link: true
    @tag engine: true
    test "break all links between two objects", %{object_id1: object_id1, object_id2: object_id2, type: link_type, data: data} = _context do
      assert Link.linked?(object_id1, object_id2) == true
      assert Link.linked?(object_id1, object_id2, link_type) == true
      assert Link.linked?(object_id1, object_id2, link_type, data) == true
      assert Link.linked?(object_id1, object_id2, link_type, data, &(&1 == &2)) == true
      assert Link.break_all(object_id1, object_id2) == :ok
      assert Link.linked?(object_id1, object_id2) == false
      assert Link.linked?(object_id1, object_id2, link_type) == false
      assert Link.linked?(object_id1, object_id2, link_type, data) == false
      assert Link.linked?(object_id1, object_id2, link_type, data, &(&1 == &2)) == false
    end

    @tag link: true
    @tag engine: true
    test "break all links between two objects in reverse", %{object_id1: object_id1, object_id2: object_id2, type: link_type, data: data} = _context do
      assert Link.linked?(object_id1, object_id2) == true
      assert Link.linked?(object_id1, object_id2, link_type) == true
      assert Link.linked?(object_id1, object_id2, link_type, data) == true
      assert Link.linked?(object_id1, object_id2, link_type, data, &(&1 == &2)) == true
      assert Link.break_all(object_id2, object_id1) == :ok
      assert Link.linked?(object_id1, object_id2) == false
      assert Link.linked?(object_id1, object_id2, link_type) == false
      assert Link.linked?(object_id1, object_id2, link_type, data) == false
      assert Link.linked?(object_id1, object_id2, link_type, data, &(&1 == &2)) == false
    end

    @tag link: true
    @tag engine: true
    test "break one link between two objects", %{object_id1: object_id1, object_id2: object_id2, type: link_type, data: data} = _context do
      assert Link.linked?(object_id1, object_id2) == true
      assert Link.linked?(object_id1, object_id2, link_type) == true
      assert Link.linked?(object_id1, object_id2, link_type, data) == true
      assert Link.linked?(object_id1, object_id2, link_type, data, &(&1 == &2)) == true
      assert Link.break_one(object_id1, object_id2, link_type) == :ok
      assert Link.linked?(object_id1, object_id2) == false
      assert Link.linked?(object_id1, object_id2, link_type) == false
      assert Link.linked?(object_id1, object_id2, link_type, data) == false
      assert Link.linked?(object_id1, object_id2, link_type, data, &(&1 == &2)) == false
    end

    @tag link: true
    @tag engine: true
    test "break one link that does not exist", %{object_id1: object_id1, object_id2: object_id2, type: link_type, data: data} = _context do
      assert Link.linked?(object_id1, object_id2) == true
      assert Link.linked?(object_id1, object_id2, link_type) == true
      assert Link.break_one(object_id2, object_id1, link_type) == {:error, :no_such_link}
    end
  end

  defp create_new_objects(context) do
    key = UUID.generate()
    {:ok, object_id1} = Object.new(key)
    key = UUID.generate()
    {:ok, object_id2} = Object.new(key)

    context
    |> Map.put(:object_id1, object_id1)
    |> Map.put(:object_id2, object_id2)
  end

  defp generate_data(context) do
    data = :crypto.strong_rand_bytes(Enum.random(1..10240))

    context
    |> Map.put(:data, data)
  end

  defp generate_link_type(context) do
    link_type = UUID.generate()

    context
    |> Map.put(:type, link_type)
  end

  defp forge_link(context) do
    :ok = Link.forge(context.object_id1, context.object_id2, context.type, context.data)
    context
  end
end