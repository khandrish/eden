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
    setup [:create_new_object, :register_test_scripts]

    @tag script: true
    @tag engine: true
    test "with successful start", %{object_id: object_id} = _context do
      assert Script.running?(object_id, Idle.name()) == false
      assert Script.start(object_id, Idle.name()) == :ok
      assert Script.is_attached?(object_id, Idle.name()) == true
      assert Script.running?(object_id, Idle.name()) == true
      assert Script.stop(object_id, Idle.name()) == :ok
      assert Script.start(object_id, Idle.name()) == :ok
    end

    @tag script: true
    @tag engine: true
    test "with getting state", %{object_id: object_id} = _context do
      assert Script.start(object_id, State.name()) == :ok
      assert Script.get_state(object_id, State.name()) == {:ok, nil}
      assert Script.stop(object_id, State.name()) == :ok
      assert Script.get_state(object_id, State.name()) == {:ok, nil}
    end

    @tag script: true
    @tag engine: true
    test "with successful stop", %{object_id: object_id} = _context do
      assert Script.start(object_id, Stop.name()) == :ok
      assert Script.stop(object_id, Stop.name()) == :ok
    end

    @tag script: true
    @tag engine: true
    test "with successful update", %{object_id: object_id} = _context do
      assert Script.start(object_id, Update.name()) == :ok
      assert Script.stop(object_id, Update.name()) == :ok
      assert Script.update(object_id, Update.name(), :bar) == :ok
      assert Script.get_state(object_id, Update.name()) == {:ok, :bar}
    end

    @tag script: true
    @tag engine: true
    test "with unsuccessful update", %{object_id: object_id} = _context do
      assert Script.start(object_id, UnsuccessfulUpdate.name()) == :ok
      assert Script.stop(object_id, UnsuccessfulUpdate.name()) == :ok
      assert Script.update(object_id, UnsuccessfulUpdate.name(), :bar) == :ok
      assert Script.get_state(object_id, UnsuccessfulUpdate.name()) == {:ok, :bar}
    end

    @tag script: true
    @tag engine: true
    test "with successful detach", %{object_id: object_id} = _context do
      assert Script.start(object_id, Detach.name()) == :ok
      assert Script.stop(object_id, Detach.name()) == :ok
      assert Script.is_attached?(object_id, Detach.name()) == true
      assert Script.detach(object_id, Detach.name()) == :ok
      assert Script.get_state(object_id, Detach.name()) == {:error, :no_such_script}
    end

    @tag script: true
    @tag engine: true
    test "with error while stopping non existing script", %{object_id: object_id} = _context do
      assert Script.stop(object_id, "foo") == {:error, :no_such_script}
    end

    @tag script: true
    @tag engine: true
    test "with successful run", %{object_id: object_id} = _context do
      assert Script.start(object_id, Run.name()) == :ok
      assert Script.run(object_id, Run.name()) == :ok
      assert Script.stop(object_id, Run.name()) == :ok
    end

    @tag script: true
    @tag engine: true
    test "with error while purging", %{object_id: object_id} = _context do
      assert Script.purge(object_id, "Foo") == {:error, :no_such_script}
    end

    @tag script: true
    @tag engine: true
    test "with successful purge", %{object_id: object_id} = _context do
      assert Script.start(object_id, Purge.name()) == :ok
      assert Script.purge(object_id, Purge.name()) == :ok
      assert Script.stop(object_id, Purge.name()) == :ok
    end

    @tag script: true
    @tag engine: true
    test "with successful call", %{object_id: object_id} = _context do
      assert Script.start(object_id, Call.name()) == :ok
      assert Script.call(object_id, Call.name(), "foo") == {:ok, "foo"}
      assert Script.stop(object_id, Call.name()) == :ok
    end

    @tag script: true
    @tag engine: true
    test "with successful cast", %{object_id: object_id} = _context do
      assert Script.start(object_id, Cast.name()) == :ok
      assert Script.cast(object_id, Cast.name(), "foo") == :ok
      assert Script.stop(object_id, Cast.name()) == :ok
    end

    @tag script: true
    @tag engine: true
    test "by listing registered scripts" do
      assert Script.list_registered() != []
    end

    @tag script: true
    @tag engine: true
    test "with failed lookup" do
      assert Script.lookup("foo") == {:error, :no_such_script}
    end

    @tag script: true
    @tag engine: true
    test "by checking registered scripts" do
      assert Script.registered?(Idle) == true
    end

    @tag script: true
    @tag engine: true
    test "by unregistering scripts" do
      assert Script.unregister(Unregister) == :ok
    end
  end

  defp create_new_object(_context) do
    object_id = Object.new!()

    %{object_id: object_id}
  end

  @scripts [Idle,
            Call,
            Cast,
            Run,
            Purge,
            Stop,
            State,
            UnsuccessfulUpdate,
            Update,
            Unregister,
            Detach,
            ErrorStarting,
            ErrorStopping,
            ErrorInitializing,
            ErrorHandlingMessage,
            RunInterval,
            RunError,
            RunErrorInterval,
            RunErrorStop,
            RunErrorStopping]

  defp register_test_scripts(context) do
    Enum.each(@scripts, &Script.register/1)

    context
  end
end