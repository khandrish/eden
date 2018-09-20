defmodule Exmud.Engine.Test.ScriptTest do
  alias Exmud.Engine.Script
  alias Exmud.Engine.Object
  alias Exmud.Engine.Repo
  require Logger
  use Exmud.Engine.Test.DBTestCase

  # Alias Script modules for use in tests
  alias Exmud.Engine.Test.Script.ErrorHandlingMessage
  alias Exmud.Engine.Test.Script.ErrorInitializing
  alias Exmud.Engine.Test.Script.ErrorStarting
  alias Exmud.Engine.Test.Script.ErrorStopping
  alias Exmud.Engine.Test.Script.Idle
  alias Exmud.Engine.Test.Script.RunInterval
  alias Exmud.Engine.Test.Script.RunError
  alias Exmud.Engine.Test.Script.RunErrorInterval
  alias Exmud.Engine.Test.Script.RunErrorStop
  alias Exmud.Engine.Test.Script.RunErrorStopping
  alias Exmud.Engine.Test.Script.Cast
  alias Exmud.Engine.Test.Script.Call
  alias Exmud.Engine.Test.Script.Run
  alias Exmud.Engine.Test.Script.Stop
  alias Exmud.Engine.Test.Script.State
  alias Exmud.Engine.Test.Script.Detach
  alias Exmud.Engine.Test.Script.Purge
  alias Exmud.Engine.Test.Script.Update
  alias Exmud.Engine.Test.Script.UnsuccessfulUpdate
  alias Exmud.Engine.Test.Script.Unregister

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
      assert Script.attach(object_id, State) == :ok
      assert Script.start(object_id, State) == :ok
      assert Script.get_state(object_id, State) == {:ok, object_id}
      assert Script.stop(object_id, State) == :ok
      assert Script.get_state(object_id, State) == {:ok, object_id}
    end

    test "by calling or starting", %{object_id: object_id} = _context do
      assert Script.call_or_start( object_id, Idle, nil ) == { :error, :no_such_script }
      assert Script.attach(object_id, Idle) == :ok
      assert Script.call_or_start( object_id, Idle, nil ) == :ok
    end

    test "with successful stop", %{object_id: object_id} = _context do
      assert Script.attach(object_id, Stop) == :ok
      assert Script.start(object_id, Stop) == :ok
      assert Script.stop(object_id, Stop) == :ok
    end

    test "with successful update", %{object_id: object_id} = _context do
      assert Script.attach(object_id, Update) == :ok
      assert Script.start(object_id, Update) == :ok
      assert Script.stop(object_id, Update) == :ok
      assert Script.update(object_id, Update, :bar) == :ok
      assert Script.get_state(object_id, Update) == {:ok, :bar}
    end

    test "with unsuccessful update", %{object_id: object_id} = _context do
      assert Script.attach(object_id, UnsuccessfulUpdate) == :ok
      assert Script.start(object_id, UnsuccessfulUpdate) == :ok
      assert Script.stop(object_id, UnsuccessfulUpdate) == :ok
      assert Script.update(object_id, UnsuccessfulUpdate, :bar) == :ok
      assert Script.get_state(object_id, UnsuccessfulUpdate) == {:ok, :bar}
    end

    test "with successful detach", %{object_id: object_id} = _context do
      assert Script.attach(object_id, Detach) == :ok
      assert Script.start(object_id, Detach) == :ok
      assert Script.stop(object_id, Detach) == :ok
      assert Script.is_attached?(object_id, Detach) == true
      assert Script.detach(object_id, Detach) == :ok
      assert Script.get_state(object_id, Detach) == {:error, :no_such_script}
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
      assert Script.attach(object_id, Purge) == :ok
      assert Script.start(object_id, Purge) == :ok
      assert Script.purge(object_id, Purge) == :ok
      assert Script.stop(object_id, Purge) == :ok
    end

    test "with successful call", %{object_id: object_id} = _context do
      assert Script.attach(object_id, Call) == :ok
      assert Script.start(object_id, Call) == :ok
      assert Script.call(object_id, Call, "foo") == {:ok, "foo"}
      assert Script.stop(object_id, Call) == :ok
    end

    test "with successful cast", %{object_id: object_id} = _context do
      assert Script.attach(object_id, Cast) == :ok
      assert Script.start(object_id, Cast) == :ok
      assert Script.cast(object_id, Cast, "foo") == :ok
      assert Script.stop(object_id, Cast) == :ok
    end
  end

  defp create_new_object(_context) do
    object_id = Object.new!()

    %{object_id: object_id}
  end
end
