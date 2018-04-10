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
  alias Exmud.Engine.Test.Script.RunOnce
  alias Exmud.Engine.Test.Script.RunInterval
  alias Exmud.Engine.Test.Script.RunError
  alias Exmud.Engine.Test.Script.RunErrorInterval
  alias Exmud.Engine.Test.Script.RunErrorStop
  alias Exmud.Engine.Test.Script.RunErrorStopping

  # Test Scripts
  alias Exmud.Engine.Test.Script.Idle

  describe "Scripts:" do
    setup [:create_new_object, :register_test_scripts]

    @tag script: true
    @tag engine: true
    test "lifecycle", %{object_id: object_id} = _context do
      assert Script.start(object_id, Idle.name()) == :ok
      assert Script.is_attached?(object_id, Idle.name()) == true
      assert Script.running?(object_id, Idle.name()) == true
      {:ok, state} = Script.get_state(object_id, Idle.name())
      assert Script.run(object_id, Idle.name()) == :ok
      assert Script.stop(object_id, Idle.name()) == :ok
      Process.sleep(10) # Give Process enough time to actually stop
      {:ok, db_state} = Script.get_state(object_id, Idle.name())
      assert state === db_state
      assert Script.running?(object_id, Idle.name()) == false
      assert Script.start(object_id, Idle.name()) == :ok
      assert Script.running?(object_id, Idle.name()) == true
      assert Script.detach(object_id, Idle.name()) == :ok
      assert Script.running?(object_id, Idle.name()) == false
      assert Script.is_attached?(object_id, Idle.name()) == false
      assert Script.start(object_id, Idle.name()) == :ok
      assert Script.is_attached?(object_id, Idle.name()) == true
      assert Script.running?(object_id, Idle.name()) == true
      assert Script.stop(object_id, Idle.name()) == :ok
    end

    @tag script: true
    @tag engine: true
    test "handling message correctly", %{object_id: object_id} = _context do
      assert Script.start(object_id, Idle.name()) == :ok
      assert Script.running?(object_id, Idle.name()) == true
      assert Script.call(object_id, Idle.name(), "ping") == {:ok, "ping"}
      assert Script.cast(object_id, Idle.name(), "ping") == :ok
      assert Script.stop(object_id, Idle.name()) == :ok
    end

    @tag script: true
    @tag engine: true
    @tag wip: true
    test "handling message with errors", %{object_id: object_id} = _context do
      assert Script.start(object_id, ErrorHandlingMessage.name()) == :ok
      assert Script.running?(object_id, ErrorHandlingMessage.name()) == true
      assert Script.call(object_id, ErrorHandlingMessage.name(), "ping") == {:error, "error"}
      assert Script.cast(object_id, ErrorHandlingMessage.name(), "ping") == :ok
      assert Script.stop(object_id, ErrorHandlingMessage.name()) == :ok
    end

    @tag script: true
    @tag engine: true
    test "Running Script RunOnce", %{object_id: object_id} = _context do
      assert Script.start(object_id, RunOnce.name()) == :ok
      assert Script.running?(object_id, RunOnce.name()) == true
      assert Script.run(object_id, RunOnce.name()) == :ok
      assert Script.stop(object_id, RunOnce.name()) == :ok
    end

    @tag script: true
    @tag engine: true
    test "Running Script RunInterval", %{object_id: object_id} = _context do
      assert Script.start(object_id, RunInterval.name()) == :ok
      assert Script.running?(object_id, RunInterval.name()) == true
      assert Script.run(object_id, RunInterval.name()) == :ok
      assert Script.stop(object_id, RunInterval.name()) == :ok
    end

    @tag script: true
    @tag engine: true
    test "Running Script RunError", %{object_id: object_id} = _context do
      assert Script.start(object_id, RunError.name()) == :ok
      assert Script.running?(object_id, RunError.name()) == true
      assert Script.run(object_id, RunError.name()) == :ok
      assert Script.stop(object_id, RunError.name()) == :ok
    end

    @tag script: true
    @tag engine: true
    test "Running Script RunErrorInterval", %{object_id: object_id} = _context do
      assert Script.start(object_id, RunErrorInterval.name()) == :ok
      assert Script.running?(object_id, RunErrorInterval.name()) == true
      assert Script.run(object_id, RunErrorInterval.name()) == :ok
      Process.sleep(10) # Give Process enough time to actually run
      assert Script.stop(object_id, RunErrorInterval.name()) == :ok
    end

    @tag script: true
    @tag engine: true
    test "Running Script RunErrorStop", %{object_id: object_id} = _context do
      assert Script.start(object_id, RunErrorStop.name()) == :ok
      assert Script.running?(object_id, RunErrorStop.name()) == true
      assert Script.run(object_id, RunErrorStop.name()) == :ok
    end

    @tag script: true
    @tag engine: true
    test "Running Script RunErrorStopping", %{object_id: object_id} = _context do
      assert Script.start(object_id, RunErrorStopping.name()) == :ok
      assert Script.running?(object_id, RunErrorStopping.name()) == true
      assert Script.run(object_id, RunErrorStopping.name()) == :ok
    end

    @tag script: true
    @tag engine: true
    test "engine registration" do
      assert Script.register(Idle) == :ok
      assert Script.registered?(Idle) == true
      assert Enum.any?(Script.list_registered(), fn(k) -> Idle.name() == k end) == true
      assert Script.lookup(Idle) == {:error, :no_such_script}
      {:ok, callback} = Script.lookup(Idle.name())
      assert callback == Idle
      assert Script.unregister(Idle) == :ok
      assert Script.registered?(Idle) == false
      assert Enum.any?(Script.list_registered(), fn(k) -> Idle.name() == k end) == false
    end

    @tag script: true
    @tag engine: true
    test "error initializing", %{object_id: object_id} = _context do
      assert Script.start(object_id, ErrorInitializing.name()) == {:error, "error"}
    end

    @tag script: true
    @tag engine: true
    test "error starting", %{object_id: object_id} = _context do
      assert Script.start(object_id, ErrorStarting.name()) == {:error, "error"}
    end

    @tag script: true
    @tag engine: true
    test "error stopping", %{object_id: object_id} = _context do
      assert Script.start(object_id, ErrorStopping.name()) == :ok
      assert Script.running?(object_id, ErrorStopping.name()) == true
      assert Script.stop(object_id, ErrorStopping.name()) == {:error, "error"}
    end

    @tag script: true
    @tag engine: true
    test "purge script data", %{object_id: object_id} = _context do
      assert Script.start(object_id, Idle.name()) == :ok
      assert Script.running?(object_id, Idle.name()) == true
      assert Script.stop(object_id, Idle.name()) == :ok
      Process.sleep(10) # Give Process enough time to actually stop
      assert Script.purge(object_id, Idle.name()) == :ok
    end

    @tag script: true
    @tag engine: true
    test "remove script", %{object_id: object_id} = _context do
      assert Script.start(object_id, Idle.name()) == :ok
      assert Script.running?(object_id, Idle.name()) == true
      assert Script.detach(object_id, Idle.name()) == :ok
      Process.sleep(10) # Give Process enough time to actually stop
      assert Script.running?(object_id, Idle.name()) == false
      assert Script.is_attached?(object_id, Idle.name()) == false
    end

    @tag script: true
    @tag engine: true
    test "cast to nonexisting Script", %{object_id: object_id} = _context do
      assert Script.cast(object_id, Idle.name(), "ping") == :ok
    end

    @tag script: true
    @tag engine: true
    test "call to nonexisting Script", %{object_id: object_id} = _context do
      assert Script.call(object_id, Idle.name(), "ping") == {:error, :script_not_running}
    end
  end

  defp create_new_object(_context) do
    key = UUID.generate()
    {:ok, object_id} = Object.new(key)

    %{key: key, object_id: object_id}
  end

  @scripts [Idle,
            ErrorStarting,
            ErrorStopping,
            ErrorInitializing,
            ErrorHandlingMessage,
            RunOnce,
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