defmodule Exmud.Engine.Test.CommandSetTest do
  alias Exmud.Engine.CommandSet
  alias Exmud.Engine.Object
  alias Exmud.Engine.Repo
  require Logger
  use Exmud.Engine.Test.DBTestCase

  alias Exmud.Engine.Test.CommandSet.Basic
  alias Exmud.Engine.Test.CommandSet.HighPriority

  describe "command set" do
    setup [ :create_new_object ]

    @tag command_set: true
    test "with successful attach", %{ object_id: object_id } = _context do
      assert CommandSet.attach( object_id, Basic ) == :ok
      assert CommandSet.attach( object_id, Basic ) == { :error, :already_attached }
    end

    @tag command_set: true
    test "with successful detach!", %{ object_id: object_id } = _context do
      assert CommandSet.attach( object_id, Basic ) == :ok
      assert CommandSet.detach( object_id, Basic ) == :ok
    end

    @tag command_set: true
    test "with has_* checks", %{ object_id: object_id } = _context do
      assert CommandSet.has_all?( object_id, Basic ) == false
      assert CommandSet.has_any?( object_id, [ Basic ] ) == false
      assert CommandSet.attach( object_id, Basic ) == :ok
      assert CommandSet.has_all?( object_id, Basic ) == true
      assert CommandSet.has_any?( object_id, [ HighPriority ] ) == false
      assert CommandSet.has_any?( object_id, [ Basic, HighPriority ] ) == true
      assert CommandSet.detach( object_id, Basic ) == :ok
      assert CommandSet.has_any?( object_id, Basic ) == false
    end

    @tag command_set: true
    test "invalid input" do
      assert CommandSet.attach( 0, Basic ) == { :error, :no_such_object }
      assert CommandSet.has_any?( 0, Basic ) == false
      assert CommandSet.has_all?( 0, Basic ) == false
      assert CommandSet.detach( 0, Basic ) == :ok
    end

    @tag command_set: true
    test "with merging", %{ object_id: object_id } = _context do
      assert CommandSet.build_active_command_list( 0, 0 ) == []
      assert CommandSet.attach( object_id, Basic ) == :ok
      assert length( CommandSet.build_active_command_list( object_id, object_id ) ) != 0
      assert CommandSet.attach( object_id, HighPriority ) == :ok
      assert length( CommandSet.build_active_command_list( object_id, object_id ) ) != 0
    end
  end

  defp create_new_object(_context) do
    object_id = Object.new!()

    %{object_id: object_id}
  end
end
