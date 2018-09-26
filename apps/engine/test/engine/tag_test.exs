defmodule Exmud.Engine.Test.TagTest do
  alias Exmud.Engine.Object
  alias Exmud.Engine.Tag
  require Logger
  use Exmud.Engine.Test.DBTestCase

  describe "Multi Ecto usage tests for tags:" do
    setup [:create_new_object]

    @tag tag: true
    @tag engine: true
    test "lifecycle", %{object_id: object_id} = _context do
      assert Tag.is_attached?(object_id, "foo", "bar") == false
      assert Tag.attach(object_id, "foo", "bar") == :ok
      assert Tag.is_attached?(object_id, "foo", "bar") == true
      assert Tag.detach(object_id, "foo", "bar") == :ok
      assert Tag.is_attached?(object_id, "foo", "bar") == false
    end

    @tag tag: true
    @tag engine: true
    test "invalid cases" do
      assert Tag.attach(0, "foo", "bar") == {:error, :no_such_object}
      assert Tag.is_attached?(0, "foo", "bar") == false
      assert Tag.detach(0, "foo", "bar") == {:error, :no_such_tag}
    end
  end

  defp create_new_object(_context) do
    object_id = Object.new!()

    %{object_id: object_id}
  end
end
