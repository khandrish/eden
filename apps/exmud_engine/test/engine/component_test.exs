defmodule Exmud.Engine.Test.ComponentTest do
  alias Ecto.UUID
  alias Exmud.Engine.Component
  alias Exmud.Engine.Object
  alias Exmud.Engine.Repo
  require Logger
  use Exmud.Engine.Test.DBTestCase

  # Test Components
  alias Exmud.Engine.Test.Component.Bad
  alias Exmud.Engine.Test.Component.Basic

  describe "components" do
    setup [:create_new_object, :register_test_components]

    @tag component: true
    @tag engine: true
    @tag wip: true
    test "lifecycle", %{object_id: object_id} = _context do
      assert Component.attach(object_id, "foo") == {:error, :no_such_component}
      assert Component.register(Basic) == :ok
      assert Component.register(Bad) == :ok
      assert Component.attach(object_id, Basic.name()) == :ok
      assert Component.attach(object_id, Bad.name()) == {:error, :fubar}
      assert Component.all_attached?(object_id, Basic.name()) == true
      assert Component.any_attached?(object_id, Basic.name()) == true
      assert Component.all_attached?(object_id, Basic.name()) == true
      assert Component.detach(object_id, Basic.name()) == :ok
      assert Component.all_attached?(object_id, Basic.name()) == false
      assert Component.attach(object_id, Basic.name()) == :ok
      assert Component.detach(object_id) == :ok
      assert Component.all_attached?(object_id, Basic.name()) == false
      assert Component.all_attached?(object_id, "foo") == false
    end

    @tag component: true
    @tag engine: true
    test "engine registration" do
      callback_module = UUID.generate()
      assert Component.register(Basic) == :ok
      assert Component.registered?(Basic) == true
      assert Enum.any?(Component.list_registered(), fn k -> Basic.name() == k end) == true
      assert Component.lookup(callback_module) == {:error, :no_such_component}
      {:ok, callback} = Component.lookup(Basic.name())
      assert callback == Basic
      assert Component.unregister(Basic) == :ok
      assert Component.registered?(Basic) == false
      assert Enum.any?(Component.list_registered(), fn k -> Basic.name() == k end) == false
    end

    @tag component: true
    @tag engine: true
    test "with wrong object_id" do
      assert Component.register(Basic) == :ok
      assert Component.attach(0, Basic.name()) == {:error, :no_such_object}
    end

    @tag component: true
    @tag engine: true
    test "with duplicate component", %{object_id: object_id} = _context do
      assert Component.register(Basic) == :ok
      assert Component.attach(object_id, Basic.name()) == :ok
      assert Component.attach(object_id, Basic.name()) == {:error, :already_attached}
    end
  end

  defp create_new_object(_context) do
    object_id = Object.new!()

    %{object_id: object_id}
  end

  @components [Basic, Bad]

  defp register_test_components(context) do
    Enum.each(@components, &Component.register/1)

    context
  end
end

defmodule Exmud.Engine.ComponentTest.BadExampleComponent do
  def populate do
    {:error, :fubar}
  end
end
