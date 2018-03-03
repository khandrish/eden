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
  alias Exmud.Engine.Test.Script.Run

  # Test Scripts
  alias Exmud.Engine.Test.Script.Idle

  describe "Tests for scripts:" do
    setup [:create_new_object, :register_test_scripts]

    @tag script: true
    @tag engine: true
    test "lifecycle", %{object_id: object_id} = _context do
      assert Script.start(object_id, Idle.name()) == {:ok, :started}
      assert Script.is_attached?(object_id, Idle.name()) == true
      assert Script.running?(object_id, Idle.name()) == true
      {:ok, state} = Script.get_state(object_id, Idle.name())
      assert Script.run(object_id, Idle.name()) == {:ok, :running}
      assert Script.stop(object_id, Idle.name()) == {:ok, :stopped}
      Process.sleep(10) # Give Process enough time to actually stop
      {:ok, db_state} = Script.get_state(object_id, Idle.name())
      assert state === db_state
      assert Script.running?(object_id, Idle.name()) == false
      assert Script.start(object_id, Idle.name()) == {:ok, :started}
      assert Script.running?(object_id, Idle.name()) == true
      assert Script.remove(object_id, Idle.name()) == {:ok, :removed}
      assert Script.running?(object_id, Idle.name()) == false
      assert Script.is_attached?(object_id, Idle.name()) == false
      assert Script.start(object_id, Idle.name()) == {:ok, :started}
      assert Script.is_attached?(object_id, Idle.name()) == true
      assert Script.running?(object_id, Idle.name()) == true
      assert Script.stop(object_id, Idle.name()) == {:ok, :stopped}
    end

    @tag script: true
    @tag engine: true
    test "handling message", %{object_id: object_id} = _context do
      assert Script.start(object_id, Idle.name()) == {:ok, :started}
      assert Script.call(object_id, Idle.name(), "ping") == {:ok, "ping"}
      assert Script.cast(object_id, Idle.name(), "ping") == :ok
      assert Script.stop(object_id, Idle.name()) == {:ok, :stopped}
      assert Script.start(object_id, ErrorHandlingMessage.name()) == {:ok, :started}
      assert Script.call(object_id, ErrorHandlingMessage.name(), "ping") == {:error, "error"}
      assert Script.cast(object_id, ErrorHandlingMessage.name(), "ping") == :ok
      assert Script.stop(object_id, ErrorHandlingMessage.name()) == {:ok, :stopped}
    end

    @tag script: true
    @tag engine: true
    test "Running Script", %{object_id: object_id} = _context do
      assert Script.start(object_id, Run.name()) == {:ok, :started}
      assert Script.run(object_id, Run.name()) == {:ok, :running}
      Process.sleep(10) # Give Process enough time to actually run
      assert Script.run(object_id, Run.name()) == {:ok, :running}
      Process.sleep(10) # Give Process enough time to run and stop itself
      assert Script.start(object_id, Run.name()) == {:ok, :started}
      assert Script.run(object_id, Run.name()) == {:ok, :running}
    end

    @tag script: true
    @tag engine: true
    test "engine registration" do
      assert Script.register(Idle) == {:ok, true}
      assert Script.registered?(Idle.name()) == true
      assert Enum.any?(Script.list_registered(), fn(k) -> Idle.name() == k end) == true
      assert Script.lookup(Idle) == {:error, :no_such_script}
      {:ok, callback} = Script.lookup(Idle.name())
      assert callback == Idle
      assert Script.unregister(Idle.name()) == {:ok, true}
      assert Script.registered?(Idle.name()) == false
      assert Enum.any?(Script.list_registered(), fn(k) -> Idle.name() == k end) == false
    end

    @tag script: true
    @tag engine: true
    test "bad scripts", %{object_id: object_id} = _context do
      assert Script.start(object_id, ErrorInitializing.name()) == {:error, "error"}
      assert Script.start(object_id, ErrorStarting.name()) == {:error, "error"}
      assert Script.start(object_id, ErrorStopping.name()) == {:ok, :started}
      assert Script.stop(object_id, ErrorStopping.name()) == {:error, "error"}
    end

    @tag script: true
    @tag engine: true
    test "purge script data", %{object_id: object_id} = _context do
      assert Script.start(object_id, Idle.name()) == {:ok, :started}
      assert Script.stop(object_id, Idle.name()) == {:ok, :stopped}
      Process.sleep(10) # Give Process enough time to actually stop
      {result, _} = Script.purge(object_id, Idle.name())
      assert result == :ok
    end

    @tag script: true
    @tag engine: true
    test "remove script", %{object_id: object_id} = _context do
      assert Script.start(object_id, Idle.name()) == {:ok, :started}
      assert Script.remove(object_id, Idle.name()) == {:ok, :removed}
      Process.sleep(10) # Give Process enough time to actually stop
      assert Script.running?(object_id, Idle.name()) == false
      assert Script.is_attached?(object_id, Idle.name()) == false
    end
  end

  defp create_new_object(_context) do
    key = UUID.generate()
    {:ok, object_id} = Object.new(key)

    %{key: key, object_id: object_id}
  end

  @scripts [Idle, ErrorStarting, ErrorStopping, ErrorInitializing, ErrorHandlingMessage, Run]

  defp register_test_scripts(context) do
    Enum.each(@scripts, &Script.register/1)

    context
  end
end