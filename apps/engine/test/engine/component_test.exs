defmodule Exmud.Engine.Test.ComponentTest do
  alias Exmud.Engine.Component
  alias Exmud.Engine.Object
  alias Exmud.Engine.Repo
  require Logger
  use Exmud.Engine.Test.DBTestCase

  # Test Components
  alias Exmud.Engine.Test.Component.Bad
  alias Exmud.Engine.Test.Component.Basic

  describe "components" do
    setup [:create_new_object]

    test "lifecycle", %{object_id: object_id} = _context do
      assert Component.attach(object_id, "foo") == {:error, :callback_failed}
      assert Component.attach(object_id, Basic) == :ok
      assert Component.attach(object_id, Bad) == {:error, :fubar}
      assert Component.all_attached?(object_id, Basic) == true
      assert Component.any_attached?(object_id, Basic) == true
      assert Component.all_attached?(object_id, Basic) == true
      assert Component.detach(object_id, Basic) == :ok
      assert Component.all_attached?(object_id, Basic) == false
      assert Component.attach(object_id, Basic) == :ok
      assert Component.detach(object_id) == :ok
      assert Component.all_attached?(object_id, Basic) == false
      assert Component.all_attached?(object_id, "foo") == false
    end

    test "with wrong object_id" do
      assert Component.attach(0, Basic) == {:error, :no_such_object}
    end

    test "with duplicate component", %{object_id: object_id} = _context do
      assert Component.attach(object_id, Basic) == :ok
      assert Component.attach(object_id, Basic) == {:error, :already_attached}
    end
  end

  defp create_new_object(_context) do
    object_id = Object.new!()

    %{object_id: object_id}
  end

end
