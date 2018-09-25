defmodule Exmud.Engine.Worker.ScriptWorkerTest do
  alias Exmud.Engine.Object
  alias Exmud.Engine.Script
  alias Exmud.Engine.Test.Script.ErrorHandlingMessage
  alias Exmud.Engine.Test.Script.ErrorInitializing
  alias Exmud.Engine.Test.Script.ErrorStarting
  alias Exmud.Engine.Test.Script.ErrorStopping
  alias Exmud.Engine.Test.Script.Idle
  alias Exmud.Engine.Test.Script.Run
  alias Exmud.Engine.Test.Script.RunError
  alias Exmud.Engine.Test.Script.RunErrorInterval
  alias Exmud.Engine.Test.Script.RunErrorStop
  alias Exmud.Engine.Test.Script.RunErrorStopping
  alias Exmud.Engine.Test.Script.RunInterval
  alias Exmud.Engine.Worker.ScriptWorker
  use Exmud.Engine.Test.DBTestCase

  describe "script runner" do
    setup [ :create_state ]

    @tag engine: true
    @tag script_runner: true
    test "during normal initialization", state do
      :ok = Script.attach( state.object_id, Idle, "normal" )
      { :ok, state } = ScriptWorker.init( { state.object_id, Idle, nil } )
      assert state.deserialized_state == "normal"
      assert state.callback_module == Idle
      assert is_reference( state.timer_ref )
      assert state.object_id == state.object_id
    end

    @tag engine: true
    @tag script_runner: true
    test "with error during start callback", state do
      Script.attach( state.object_id, ErrorStarting )
      { :stop, "badness" } =
        ScriptWorker.init( { state.object_id, ErrorStarting, "badness" } )
    end

    @tag engine: true
    @tag script_runner: true
    test "successfully handling run call", state do
      { :reply, :ok, _state } = ScriptWorker.handle_call( :run, nil, state )
    end

    @tag engine: true
    @tag script_runner: true
    test "successfully handling message call", state do
      state = %{ state | callback_module: Idle, script_name: Idle }
      { :reply, { :ok, "foo" }, _state } = ScriptWorker.handle_call( { :message, "foo" }, nil, state )
    end

    @tag engine: true
    @tag script_runner: true
    test "with error while handling message call", state do
      state = %{
        state
        | callback_module: ErrorHandlingMessage,
          script_name: ErrorHandlingMessage
      }

      { :reply, { :error, "foo" }, _state } = ScriptWorker.handle_call( { :message, "foo" }, nil, state )
    end

    @tag engine: true
    @tag script_runner: true
    test "successfully handling message cast", state do
      state = %{ state | callback_module: Idle, script_name: Idle }
      { :noreply, _state } = ScriptWorker.handle_cast( { :message, "foo" }, state )
    end

    @tag engine: true
    @tag script_runner: true
    test "successfully handling state call", state do
      state = %{
        state
        | callback_module: Idle,
          script_name: Idle,
          deserialized_state: "foo"
      }

      { :reply, { :ok, "foo" }, _state } = ScriptWorker.handle_call( :state, nil, state )
    end

    @tag engine: true
    @tag script_runner: true
    test "successfully handling running call", state do
      state = %{ state | callback_module: Idle, script_name: Idle }
      { :reply, true, _state } = ScriptWorker.handle_call( :running, nil, state )
    end

    @tag engine: true
    @tag script_runner: true
    test "successfully handling stop call", state do
      state = %{ state | callback_module: Idle, script_name: Idle }
      { :reply, :ok, _state } = ScriptWorker.handle_call( { :stop, nil }, nil, state )
    end

    @tag engine: true
    @tag script_runner: true
    test "with error while handling stop call", state do
      state = %{ state | callback_module: ErrorStopping, script_name: ErrorStopping }
      { :reply, { :error, "foo" }, _state } = ScriptWorker.handle_call( { :stop, "foo" }, nil, state )
    end

    @tag engine: true
    @tag script_runner: true
    test "successfully handling run while persisting changed state", state do
      state = %{ state | callback_module: Run, script_name: Run }
      :ok = Script.attach( state.object_id, Run, "normal" )
      { :ok, state } = ScriptWorker.init( { state.object_id, Run, nil } )
      { :noreply, _state } = ScriptWorker.handle_info( :run, state )
    end

    @tag engine: true
    @tag script_runner: true
    test "successfully handling run with interval", state do
      state = %{ state | callback_module: RunInterval, script_name: RunInterval }
      { :noreply, state } = ScriptWorker.handle_info( :run, state )
      assert is_reference( state.timer_ref )
    end

    @tag engine: true
    @tag script_runner: true
    test "with error handling run", state do
      state = %{ state | callback_module: RunError, script_name: RunError }
      { :noreply, state } = ScriptWorker.handle_info( :run, state )
      assert is_reference( state.timer_ref ) == false
    end

    @tag engine: true
    @tag script_runner: true
    test "with error handling run with interval", state do
      state = %{ state | callback_module: RunErrorInterval, script_name: RunErrorInterval }
      { :noreply, state } = ScriptWorker.handle_info( :run, state )
      assert is_reference( state.timer_ref )
    end

    @tag engine: true
    @tag script_runner: true
    test "with error handling run with stop", state do
      state = %{ state | callback_module: RunErrorStop, script_name: RunErrorStop }
      { :stop, :normal, state } = ScriptWorker.handle_info( :run, state )
      assert is_reference( state.timer_ref ) == false
    end

    @tag engine: true
    @tag script_runner: true
    test "by stopping and then having an error during stopping", state do
      state = %{ state | callback_module: RunErrorStopping, script_name: RunErrorStopping }
      { :stop, :normal, _state } = ScriptWorker.handle_info( :run, state )
    end

    @tag engine: true
    @tag script_runner: true
    test "with info with :stop as message", state do
      state = %{ state | callback_module: RunErrorStop, script_name: RunErrorStop }
      { :stop, :normal, _state } = ScriptWorker.handle_info( :stop, state )
    end
  end

  defp create_state( _context ) do
    %{
      callback_module: nil,
      deserialized_state: nil,
      object_id: Object.new!(),
      script_name: nil,
      timer_ref: Process.send_after( self(), :foo, 60_000 )
    }
  end
end
