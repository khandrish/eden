defmodule Exmud.Engine.SystemTest do
  alias Exmud.Engine.System
  use Exmud.Engine.Test.DBTestCase

  # Test Systems
  alias Exmud.Engine.Test.System.Idle
  alias Exmud.Engine.Test.System.Interval
  alias Exmud.Engine.Test.System.Run
  alias Exmud.Engine.Test.System.Stop

  describe "system" do
    setup [:register_test_systems]

    @tag system: true
    @tag engine: true
    test "with successful start" do
      assert System.start(Idle.name()) == :ok
      assert System.running?(Idle.name()) == true
      assert System.stop(Idle.name()) == :ok
      assert System.running?(Idle.name()) == false
    end

    @tag system: true
    @tag engine: true
    test "with running check on nonexisting system" do
      assert System.running?("foo") == false
    end

    @tag system: true
    @tag engine: true
    test "with getting state" do
      assert System.start(Interval.name()) == :ok
      assert System.get_state(Interval.name()) == {:ok, nil}
      assert System.stop(Interval.name()) == :ok
      assert System.get_state(Interval.name()) == {:ok, nil}
    end

    @tag system: true
    @tag engine: true
    test "with successful stop" do
      assert System.start(Stop.name()) == :ok
      assert System.stop(Stop.name()) == :ok
    end

    @tag system: true
    @tag engine: true
    test "with error while stopping" do
      assert System.stop("foo") == {:error, :system_not_running}
    end

    @tag system: true
    @tag engine: true
    test "with successful run" do
      assert System.start(Run.name()) == :ok
      assert System.run(Run.name()) == :ok
    end
  end

  @systems [Idle, Interval, Run, Stop]
  defp register_test_systems(context) do
    Enum.each(@systems, &System.register/1)

    context
  end
end
