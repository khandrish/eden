defmodule Exmud.Engine.Test.ScriptTest do
  alias Exmud.Engine.Script
  alias Exmud.Engine.Object
  alias Exmud.Engine.Repo
  require Logger
  use Exmud.Engine.Test.DBTestCase

  # Alias Script modules for use in tests
  alias Exmud.Engine.Test.Script.Basic
  alias Exmud.Engine.Test.Script.Idle
  alias Exmud.Engine.Test.Script.Run

  describe "scripts interface" do
    setup [ :create_new_object ]

    test "by stopping and starting", %{object_id: object_id} = _context do
      assert Script.running?(object_id, Idle) == false
      assert Script.attach(object_id, Idle) == :ok
      assert Script.is_attached?(object_id, Idle) == true
      assert Script.running?(object_id, Idle) == false
      assert Script.start(object_id, Idle) == :ok
      assert Script.running?(object_id, Idle) == true
      assert Script.stop(object_id, Idle) == :ok
      assert Script.running?(object_id, Idle) == false
    end

    test "by getting state", %{object_id: object_id} = _context do
      assert Script.attach(object_id, Basic) == :ok
      assert Script.start(object_id, Basic) == :ok
      assert Script.get_state(object_id, Basic) == {:ok, object_id}
      assert Script.stop(object_id, Basic) == :ok
      assert Script.get_state(object_id, Basic) == {:ok, object_id}
    end

    test "by calling or starting", %{object_id: object_id} = _context do
      assert Script.call_or_start( object_id, Idle, nil ) == { :error, :no_such_script }
      assert Script.attach(object_id, Idle) == :ok
      assert Script.call_or_start( object_id, Idle, nil ) == :ok
    end

    test "with successful stop", %{object_id: object_id} = _context do
      assert Script.attach(object_id, Basic) == :ok
      assert Script.start(object_id, Basic) == :ok
      assert Script.stop(object_id, Basic) == :ok
    end

    test "with successful update", %{object_id: object_id} = _context do
      assert Script.attach(object_id, Basic) == :ok
      assert Script.start(object_id, Basic) == :ok
      assert Script.stop(object_id, Basic) == :ok
      assert Script.update(object_id, Basic, :bar) == :ok
      assert Script.get_state(object_id, Basic) == {:ok, :bar}
    end

    test "with successful detach", %{object_id: object_id} = _context do
      assert Script.attach(object_id, Basic) == :ok
      assert Script.start(object_id, Basic) == :ok
      assert Script.stop(object_id, Basic) == :ok
      assert Script.is_attached?(object_id, Basic) == true
      assert Script.detach(object_id, Basic) == :ok
      assert Script.get_state(object_id, Basic) == {:error, :no_such_script}
    end

    test "with error while stopping non existing script", %{object_id: object_id} = _context do
      assert Script.stop(object_id, "foo") == {:error, :no_such_script}
    end

    test "with successful run", %{object_id: object_id} = _context do
      assert Script.attach(object_id, Run) == :ok
      assert Script.start(object_id, Run) == :ok
      assert Script.run(object_id, Run) == :ok
      assert Script.stop(object_id, Run) == :ok
    end

    test "with error while purging", %{object_id: object_id} = _context do
      assert Script.purge(object_id, Idle) == {:error, :no_such_script}
    end

    test "with successful purge", %{object_id: object_id} = _context do
      assert Script.attach(object_id, Basic) == :ok
      assert Script.start(object_id, Basic) == :ok
      assert Script.purge(object_id, Basic) == :ok
      assert Script.stop(object_id, Basic) == :ok
    end

    test "with successful call", %{object_id: object_id} = _context do
      assert Script.attach(object_id, Basic) == :ok
      assert Script.start(object_id, Basic) == :ok
      assert Script.call(object_id, Basic, "foo") == {:ok, "foo"}
      assert Script.stop(object_id, Basic) == :ok
    end

    test "with successful cast", %{object_id: object_id} = _context do
      assert Script.attach(object_id, Basic) == :ok
      assert Script.start(object_id, Basic) == :ok
      assert Script.cast(object_id, Basic, "foo") == :ok
      assert Script.stop(object_id, Basic) == :ok
    end
  end

  defp create_new_object(_context) do
    object_id = Object.new!()

    %{object_id: object_id}
  end
end
