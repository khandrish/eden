defmodule Exmud.Engine.Test.ScriptTest do
  alias Ecto.UUID
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

  describe "scripts interface" do
    setup [:create_new_object, :register_test_scripts]

    @tag script: true
    @tag engine: true
    test "with successful start", %{object_id: object_id} = _context do
      assert Script.running?(object_id, Idle.name()) == false
      assert Script.start(object_id, Idle.name()) == :ok
      assert Script.is_attached?(object_id, Idle.name()) == true
      assert Script.running?(object_id, Idle.name()) == true
    end

    @tag script: true
    @tag engine: true
    test "with getting state", %{object_id: object_id} = _context do
      assert Script.start(object_id, Idle.name()) == :ok
      assert Script.get_state(object_id, Idle.name()) == {:ok, nil}
    end

    @tag script: true
    @tag engine: true
    test "with successful stop", %{object_id: object_id} = _context do
      assert Script.start(object_id, Idle.name()) == :ok
      assert Script.stop(object_id, Idle.name()) == :ok
    end

    @tag script: true
    @tag engine: true
    test "with successful detach", %{object_id: object_id} = _context do
      assert Script.start(object_id, Idle.name()) == :ok
      assert Script.stop(object_id, Idle.name()) == :ok
      assert Script.is_attached?(object_id, Idle.name()) == true
      assert Script.detach(object_id, Idle.name()) == :ok
      assert Script.get_state(object_id, Idle.name()) == {:error, :no_such_script}
    end

    @tag script: true
    @tag engine: true
    test "with error while stopping", %{object_id: object_id} = _context do
      assert Script.stop(object_id, "foo") == {:error, :no_such_script}
    end

    @tag script: true
    @tag engine: true
    test "with error while detaching", %{object_id: object_id} = _context do
      assert Script.stop(object_id, "foo") == {:error, :no_such_script}
    end

    @tag script: true
    @tag engine: true
    test "with successful run", %{object_id: object_id} = _context do
      assert Script.start(object_id, Idle.name()) == :ok
      assert Script.run(object_id, Idle.name()) == :ok
    end

    @tag script: true
    @tag engine: true
    test "with error while purging", %{object_id: object_id} = _context do
      assert Script.purge(object_id, Idle.name()) == {:error, :no_such_script}
    end

    @tag script: true
    @tag engine: true
    test "with successful purge", %{object_id: object_id} = _context do
      assert Script.start(object_id, Idle.name()) == :ok
      assert Script.purge(object_id, Idle.name()) == :ok
    end
  end

  defp create_new_object(_context) do
    object_id = Object.new!()

    %{object_id: object_id}
  end

  @scripts [Idle,
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