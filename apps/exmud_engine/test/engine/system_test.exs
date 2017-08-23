defmodule Exmud.Engine.SystemTest do
  alias Exmud.Engine.System
  use Exmud.Engine.Test.DBTestCase

  describe "system tests: " do
    setup [:do_setup]

    @tag engine: true
    @tag system: true
    test "regular lifecycle", %{interval_key: key} = _context do
      assert System.start(key) == {:ok, :started}
      assert System.start(key) == {:error, :already_started} # Can't start two of the same key
      assert System.running?(key) == {:ok, true}
      assert System.get_state(key) == {:ok, nil}
      assert System.call(key, "foo") == {:ok, "foo"}
      assert System.cast(key, "foo") == {:ok, true}
      assert System.stop(key) == {:ok, :stopped}
      assert System.get_state(key) == {:ok, nil}
      Process.sleep(10) # Give System enough time to actually shut down and deregister
      assert System.running?(key) == {:ok, false}
      assert System.start(key) == {:ok, :started} # Start again just to make sure everything was shutdown/deregistered
      assert System.stop(key) == {:ok, :stopped}
      Process.sleep(10) # Give System enough time to actually shut down and deregister
      assert System.get_state(key) == {:ok, nil}
      assert System.running?(key) == {:ok, false}
      assert System.purge(key) == {:ok, nil}
    end

    @tag engine: true
    @tag system: true
    test "idle lifecycle", %{idle_key: key} = _context do
      assert System.start(key) == {:ok, :started}
      assert System.running?(key) == {:ok, true}
      assert System.call(key, "foo") == {:ok, "foo"}
      assert System.stop(key) == {:ok, :stopped}
    end

    @tag engine: true
    @tag system: true
    test "engine registration", %{idle_system: callback_module, idle_key: key} = _context do
      assert System.registered?(key) == {:ok, true}
      assert Enum.any?(System.list_registered(), fn(k) -> key == k end) == true
      {:ok, callback} = System.lookup(key)
      assert callback == callback_module
      assert System.unregister(key) == {:ok, true}
      assert System.registered?(key) == {:ok, false}
      assert Enum.any?(System.list_registered(), fn(k) -> key == k end) == false
    end

    @tag engine: true
    @tag system: true
    test "invalid calls", _context do
      assert System.start("foo") == {:error, :no_such_system}
      assert System.stop("foo") == {:error, :system_not_running}
      assert System.call("foo", "foo") == {:error, :system_not_running}
      assert System.cast("foo", "foo") == {:ok, :true}
      assert System.purge("foo") == {:error, :no_such_system}
      assert System.lookup("foo") == {:error, :no_such_system}
    end
  end

  defp do_setup(_context) do
    {:ok, true} = System.register("Interval", Exmud.Engine.Test.System.Interval)
    {:ok, true} = System.register("Idle", Exmud.Engine.Test.System.Idle)

    %{interval_system: Exmud.Engine.Test.System.Interval, interval_key: "Interval",
      idle_system: Exmud.Engine.Test.System.Idle, idle_key: "Idle"}
  end
end
