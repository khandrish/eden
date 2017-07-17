defmodule Exmud.Engine.SystemTest do
  alias Exmud.Engine.System
  use Exmud.Engine.Test.DBTestCase

  describe "system tests: " do
    setup [:do_setup]

    @tag engine: true
    @tag system: true
    test "regular lifecycle", %{es: callback_module, es_key: key} = _context do
      assert System.start(key, callback_module) == {:ok, true}
      assert System.start(key, callback_module) == {:error, :already_started} # Can't start two of the same key
      assert System.running(key) == {:ok, true}
      assert System.get_state(key) == {:ok, %{}}
      assert System.call(key, "foo") == {:ok, "foo"}
      assert System.cast(key, "foo") == {:ok, true}
      assert System.stop(key) == {:ok, true}
      assert System.get_state(key) == {:ok, %{}}
      Process.sleep(10) # Give System enough time to actually shut down and deregister
      assert System.running(key) == {:ok, false}
      assert System.start(key, callback_module) == {:ok, true} # Start again just to make sure everything was shutdown/deregistered
      assert System.stop(key) == {:ok, true}
      Process.sleep(10) # Give System enough time to actually shut down and deregister
      assert System.get_state(key) == {:ok, %{}}
      assert System.running(key) == {:ok, false}
      assert System.purge(key) == {:ok, %{}}
    end

    @tag engine: true
    @tag system: true
    test "idle lifecycle", %{ies: callback_module, ies_key: key} = _context do
      assert System.start(key, callback_module) == {:ok, true}
      assert System.running(key) == {:ok, true}
      assert System.call(key, "foo") == {:ok, "foo"}
      assert System.stop(key) == {:ok, true}
    end

    @tag engine: true
    @tag system: true
    test "engine registration", %{ies: callback_module, ies_key: key} = _context do
      assert System.register(key, callback_module) == {:ok, true}
      assert System.registered(key) == {:ok, true}
      {:ok, {callback, _}} = System.get_registered_callback(key)
      assert callback == callback_module
      assert System.unregister(key) == {:ok, true}
      assert System.registered(key) == {:ok, false}
    end

    @tag engine: true
    @tag system: true
    test "invalid calls", _context do
      assert System.start("foo") == {:error, :no_such_system}
      assert System.stop("foo") == {:error, :system_not_running}
      assert System.call("foo", "foo") == {:error, :system_not_running}
      assert System.cast("foo", "foo") == {:error, :system_not_running}
      assert System.purge("foo") == {:error, :no_such_system}
      assert System.get_registered_callback("foo") == {:error, :no_such_system}
    end
  end

  defp do_setup(_context) do
    {:ok, true} = System.register("ExampleSystem", Exmud.Engine.SystemTest.ExampleSystem)
    {:ok, true} = System.register("IdleExampleSystem", Exmud.Engine.SystemTest.ExampleSystemIdle)

    %{es: Exmud.Engine.SystemTest.ExampleSystem, es_key: "ExampleSystem",
      ies: Exmud.Engine.SystemTest.ExampleSystemIdle, ies_key: "IdleExampleSystem"}
  end
end

defmodule Exmud.Engine.SystemTest.ExampleSystem do
  @moduledoc """
  A barebones example of a system for testing.
  """

  use Exmud.Engine.System

  def start(_args, state) do
    {:ok, state, 50}
  end

  def run(state) do
    {:ok, state, 1_000}
  end
end

defmodule Exmud.Engine.SystemTest.ExampleSystemIdle do
  @moduledoc """
  A barebones example of a system for testing.
  """

  use Exmud.Engine.System

  def handle_message(message, state) do
    {:ok, message, state, :never}
  end

  def run(state) do
    {:ok, state, :never}
  end
end