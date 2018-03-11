defmodule Exmud.Engine.SystemTest do
  alias Exmud.Engine.System
  use Exmud.Engine.Test.DBTestCase

  # Test Systems
  alias Exmud.Engine.Test.System.Idle
  alias Exmud.Engine.Test.System.Interval

  describe "system tests: " do
    setup [:register_test_systems]

    @tag engine: true
    @tag system: true
    test "regular lifecycle" do
      assert System.start(Interval.name()) == :ok
      assert System.start(Interval.name()) == {:error, :already_started} # Can't start two of the same key
      assert System.running?(Interval.name()) == true
      assert System.get_state(Interval.name()) == {:ok, nil}
      assert System.call(Interval.name(), "foo") == {:ok, "foo"}
      assert System.cast(Interval.name(), "foo") == :ok
      assert System.stop(Interval.name()) == :ok
      assert System.get_state(Interval.name()) == {:ok, nil}
      Process.sleep(10) # Give System enough time to actually shut down and deregister
      assert System.running?(Interval.name()) == false
      assert System.start(Interval.name()) == :ok # Start again just to make sure everything was shutdown/deregistered
      assert System.stop(Interval.name()) == :ok
      Process.sleep(10) # Give System enough time to actually shut down and deregister
      assert System.get_state(Interval.name()) == {:ok, nil}
      assert System.running?(Interval.name()) == false
      assert System.purge(Interval.name()) == {:ok, nil}
    end

    @tag engine: true
    @tag system: true
    test "idle lifecycle" do
      assert System.start(Idle.name()) == :ok
      assert System.running?(Idle.name()) == true
      assert System.call(Idle.name(), "foo") == {:ok, "foo"}
      assert System.stop(Idle.name()) == :ok
    end

    @tag engine: true
    @tag system: true
    test "engine registration" do
      assert System.registered?(Idle) == true
      assert Enum.any?(System.list_registered(), fn(k) -> Idle.name() == k end) == true
      {:ok, callback} = System.lookup(Idle.name())
      assert callback == Idle
      assert System.unregister(Idle) == :ok
      assert System.registered?(Idle) == false
      assert Enum.any?(System.list_registered(), fn(k) -> Idle.name() == k end) == false
    end

    @tag engine: true
    @tag system: true
    test "invalid calls", _context do
      assert System.start("foo") == {:error, :no_such_system}
      assert System.stop("foo") == {:error, :system_not_running}
      assert System.call("foo", "foo") == {:error, :system_not_running}
      assert System.cast("foo", "foo") == :ok
      assert System.purge("foo") == {:error, :no_such_system}
      assert System.lookup("foo") == {:error, :no_such_system}
    end

    @systems [Idle, Interval]

    defp register_test_systems(context) do
      Enum.each(@systems, &System.register/1)

      context
    end
  end
end
