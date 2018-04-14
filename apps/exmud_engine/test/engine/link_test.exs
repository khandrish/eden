defmodule Exmud.Engine.Test.LinkTest do
  alias Ecto.UUID
  alias Exmud.Engine.Link
  alias Exmud.Engine.Object
  require Logger
  use Exmud.Engine.Test.DBTestCase

  describe "Unlinked tests:" do
    setup [:create_new_objects, :generate_link_types, :generate_data]

    @tag link: true
    @tag engine: true
    test "forge link with no data", %{object_id1: object_id1, object_id2: object_id2, type1: link_type} = _context do
      assert Link.forge(object_id1, object_id2, link_type) == :ok
      assert Link.exists?(object_id1, object_id2) == true
      assert Link.exists?(object_id1, object_id2, link_type) == true
      assert Link.exists?(object_id1, object_id2, link_type, nil) == true
      assert Link.exists?(object_id1, object_id2, link_type, &(nil == &1)) == true
    end

    @tag link: true
    @tag engine: true
    test "forge link with data", %{object_id1: object_id1, object_id2: object_id2, type1: link_type, data1: data} = _context do
      assert Link.forge(object_id1, object_id2, link_type, data) == :ok
      assert Link.exists?(object_id1, object_id2) == true
      assert Link.exists?(object_id1, object_id2, link_type) == true
      assert Link.exists?(object_id1, object_id2, link_type, data) == true
      assert Link.exists?(object_id1, object_id2, link_type, &(data == &1)) == true
    end
  end

  describe "Linked tests:" do
    setup [:create_new_objects, :generate_link_types, :generate_data, :forge_links]

    @tag link: true
    @tag engine: true
    test "break all links on a single object", %{object_id1: object_id1, object_id2: object_id2, type1: link_type, data1: data} = _context do
      assert Link.break_all(object_id1) == :ok
      assert Link.exists?(object_id1, object_id2) == false
      assert Link.exists?(object_id1, object_id2, link_type) == false
      assert Link.exists?(object_id1, object_id2, link_type, data) == false
      assert Link.exists?(object_id1, object_id2, link_type, &(data == &1)) == false
    end

    @tag link: true
    @tag engine: true
    test "break all links between two objects", %{object_id1: object_id1, object_id2: object_id2, type1: link_type, data1: data} = _context do
      assert Link.break_all(object_id1, object_id2) == :ok
      assert Link.exists?(object_id1, object_id2) == false
      assert Link.exists?(object_id1, object_id2, link_type) == false
      assert Link.exists?(object_id1, object_id2, link_type, data) == false
      assert Link.exists?(object_id1, object_id2, link_type, &(data == &1)) == false
    end

    @tag link: true
    @tag engine: true
    test "break all links between two objects in reverse", %{object_id1: object_id1, object_id2: object_id2, type1: link_type, data1: data} = _context do
      assert Link.break_all(object_id2, object_id1) == :ok
      assert Link.exists?(object_id1, object_id2) == false
      assert Link.exists?(object_id1, object_id2, link_type) == false
      assert Link.exists?(object_id1, object_id2, link_type, data) == false
      assert Link.exists?(object_id1, object_id2, link_type, &(data == &1)) == false
    end

    @tag link: true
    @tag engine: true
    test "break all links of a specific type between two objects", %{object_id1: object_id1, object_id2: object_id2, type1: link_type1, type2: link_type2, data1: data1, data2: data2} = _context do
      assert Link.break_all(object_id2, object_id1, link_type1) == :ok
      assert Link.exists?(object_id1, object_id2) == true
      assert Link.exists?(object_id1, object_id2, link_type1) == false
      assert Link.exists?(object_id2, object_id1, link_type2) == true
      assert Link.exists?(object_id1, object_id2, link_type1, data1) == false
      assert Link.exists?(object_id2, object_id1, link_type2, data2) == true
    end

    @tag link: true
    @tag engine: true
    test "break all links of a specific type with matching data between two objects", %{object_id1: object_id1, object_id2: object_id2, type1: link_type1, type2: link_type2, data1: data1} = _context do
      assert Link.break_all(object_id1, object_id2, link_type1, data1) == :ok
      assert Link.exists?(object_id1, object_id2) == true
      assert Link.exists?(object_id1, object_id2, link_type1) == false
      assert Link.exists?(object_id1, object_id2, link_type2) == true
    end

    @tag link: true
    @tag engine: true
    test "break all links of a specific type with matching fun between two objects", %{object_id1: object_id1, object_id2: object_id2, type1: link_type1, type2: link_type2} = _context do
      assert Link.break_all(object_id1, object_id2, link_type1, fn _ -> true end) == :ok
      assert Link.exists?(object_id1, object_id2) == true
      assert Link.exists?(object_id1, object_id2, link_type1) == false
      assert Link.exists?(object_id1, object_id2, link_type2) == true
    end

    @tag link: true
    @tag engine: true
    test "break one link between two objects", %{object_id1: object_id1, object_id2: object_id2, type1: link_type1, type2: link_type2, data1: data1, data2: data2} = _context do
      assert Link.break_one(object_id1, object_id2, link_type1) == :ok
      assert Link.exists?(object_id1, object_id2) == true
      assert Link.exists?(object_id1, object_id2, link_type1) == false
      assert Link.exists?(object_id1, object_id2, link_type2) == true
      assert Link.exists?(object_id1, object_id2, link_type1, data1) == false
      assert Link.exists?(object_id1, object_id2, link_type2, data2) == true
      assert Link.exists?(object_id1, object_id2, link_type1, &(data1 == &1)) == false
      assert Link.exists?(object_id1, object_id2, link_type2, &(data2 == &1)) == true
    end

    @tag link: true
    @tag engine: true
    test "check if any links exist", %{object_id1: object_id1, object_id2: object_id2} = _context do
      assert Link.any_exist?(object_id1, object_id2) == true
    end

    @tag link: true
    @tag engine: true
    test "check if any links exist of a specific type", %{object_id1: object_id1, object_id2: object_id2, type1: link_type1} = _context do
      assert Link.any_exist?(object_id1, object_id2, link_type1) == true
    end

    @tag link: true
    @tag engine: true
    test "check if any links exist of a specific type and data", %{object_id1: object_id1, object_id2: object_id2, type1: link_type1, data1: data1} = _context do
      assert Link.any_exist?(object_id1, object_id2, link_type1, data1) == true
    end

    @tag link: true
    @tag engine: true
    test "check if any links exist of a specific type with a comparison fun", %{object_id1: object_id1, object_id2: object_id2, type1: link_type1, data1: data1} = _context do
      assert Link.any_exist?(object_id1, object_id2, link_type1, &(data1 == &1)) == true
    end

    @tag link: true
    @tag engine: true
    test "break one link that does not exist", %{object_id1: object_id1, object_id2: object_id2} = _context do
      assert Link.break_one(object_id2, object_id1, "foo") == {:error, :no_such_link}
    end

    @tag link: true
    @tag engine: true
    test "update one link", %{object_id1: object_id1, object_id2: object_id2, type1: link_type1, data1: data1, data2: data2} = _context do
      assert Link.update(object_id1, object_id2, link_type1, data2) == :ok
      assert Link.exists?(object_id1, object_id2, link_type1, data1) == false
      assert Link.exists?(object_id1, object_id2, link_type1, data2) == true
    end

    @tag link: true
    @tag engine: true
    test "update all links", %{object_id1: object_id1, object_id2: object_id2, type1: link_type1, data1: data1, data2: data2} = _context do
      assert Link.update_all(object_id1, object_id2, link_type1, data2) == :ok
      assert Link.exists?(object_id1, object_id2, link_type1, data1) == false
      assert Link.exists?(object_id1, object_id2, link_type1, data2) == true
      assert Link.exists?(object_id2, object_id1, link_type1, data1) == false
      assert Link.exists?(object_id2, object_id1, link_type1, data2) == true
    end
  end

  defp create_new_objects(context) do
    object_id1 = Object.new!()
    object_id2 = Object.new!()

    context
    |> Map.put(:object_id1, object_id1)
    |> Map.put(:object_id2, object_id2)
  end

  defp generate_data(context) do
    data1 = :crypto.strong_rand_bytes(Enum.random(1..10240))
    data2 = :crypto.strong_rand_bytes(Enum.random(1..10240))

    context
    |> Map.put(:data1, data1)
    |> Map.put(:data2, data2)
  end

  defp generate_link_types(context) do
    link_type1 = UUID.generate()
    link_type2 = UUID.generate()

    context
    |> Map.put(:type1, link_type1)
    |> Map.put(:type2, link_type2)
  end

  defp forge_links(context) do
    :ok = Link.forge_both(context.object_id1, context.object_id2, context.type1, context.data1)
    :ok = Link.forge_both(context.object_id1, context.object_id2, context.type2, context.data2)
    context
  end
end