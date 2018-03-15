defmodule Exmud.Engine.Test.LinkTest do
  alias Ecto.UUID
  alias Exmud.Engine.Link
  alias Exmud.Engine.Object
  require Logger
  use Exmud.Engine.Test.DBTestCase

  describe "Usage tests for attributes:" do
    setup [:create_new_objects]

    @tag link: true
    @tag engine: true
    test "lifecycle", %{object_id1: object_id1, object_id2: object_id2} = _context do
      link_type = UUID.generate()
      data = UUID.generate()
      assert Link.forge(object_id1, object_id2, link_type, data) == :ok
      assert Link.linked?(object_id1, object_id2) == true
      assert Link.linked?(object_id1, object_id2, link_type) == true
      assert Link.linked?(object_id1, object_id2, link_type, data) == true
      assert Link.linked(object_id1, object_id2, link_type, data, fn _, _ -> true end) == {:ok, true}
    end
  end

  defp create_new_objects(_context) do
    key = UUID.generate()
    {:ok, object_id1} = Object.new(key)
    key = UUID.generate()
    {:ok, object_id2} = Object.new(key)

    %{object_id1: object_id1, object_id2: object_id2}
  end
end