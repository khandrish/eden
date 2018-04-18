defmodule Exmud.Engine.SystemTest do
  alias Exmud.Engine.System
  use Exmud.Engine.Test.DBTestCase

  # Test Systems
  alias Exmud.Engine.Test.System.Idle
  alias Exmud.Engine.Test.System.Interval
  alias Exmud.Engine.Test.System.Run
  alias Exmud.Engine.Test.System.Stop
  alias Exmud.Engine.Test.System.Call
  alias Exmud.Engine.Test.System.Cast
  alias Exmud.Engine.Test.System.Purge
  alias Exmud.Engine.Test.System.Update
  alias Exmud.Engine.Test.System.UnsuccessfulUpdate
  alias Exmud.Engine.Test.System.Unregister

  describe "system" do
    setup [:register_test_systems]

    @tag system: true
    @tag engine: true
    test "with successful start" do
      assert System.start(Idle.name()) == :ok
      assert System.running?(Idle.name()) == true
      assert System.stop(Idle.name()) == :ok
      assert System.running?(Idle.name()) == false
      assert System.start(Idle.name()) == :ok
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
      assert System.stop("foo") == {:error, :no_such_system}
    end

    @tag system: true
    @tag engine: true
    test "with successful run" do
      assert System.start(Run.name()) == :ok
      assert System.run(Run.name()) == :ok
    end

    @tag system: true
    @tag engine: true
    test "with successful call" do
      assert System.start(Call.name()) == :ok
      assert System.call(Call.name(), "foo") == {:ok, "foo"}
      assert System.stop(Call.name()) == :ok
    end

    @tag system: true
    @tag engine: true
    test "with successful cast" do
      assert System.start(Cast.name()) == :ok
      assert System.cast(Cast.name(), "foo") == :ok
      assert System.stop(Cast.name()) == :ok
    end

    @tag system: true
    @tag engine: true
    test "with successful purge" do
      assert System.start(Purge.name()) == :ok
      assert System.purge(Purge.name()) == :ok
      assert System.stop(Purge.name()) == :ok
    end

    @tag system: true
    @tag engine: true
    test "with error while purging" do
      assert System.purge("foo") == {:error, :no_such_system}
    end

    @tag system: true
    @tag engine: true
    test "with successful update" do
      assert System.start(Update.name()) == :ok
      assert System.stop(Update.name()) == :ok
      assert System.update(Update.name(), :bar) == :ok
      assert System.get_state(Update.name()) == {:ok, :bar}
    end

    @tag system: true
    @tag engine: true
    test "with unsuccessful update" do
      assert System.start(UnsuccessfulUpdate.name()) == :ok
      assert System.stop(UnsuccessfulUpdate.name()) == :ok
      assert System.update(UnsuccessfulUpdate.name(), :bar) == :ok
      assert System.get_state(UnsuccessfulUpdate.name()) == {:ok, :bar}
    end

    @tag system: true
    @tag engine: true
    test "by listing registered systems" do
      assert System.list_registered() != []
    end

    @tag system: true
    @tag engine: true
    test "with failed lookup" do
      assert System.lookup("foo") == {:error, :no_such_system}
    end

    @tag system: true
    @tag engine: true
    test "by checking registered systems" do
      assert System.registered?(Idle) == true
    end

    @tag system: true
    @tag engine: true
    test "by unregistering systems" do
      assert System.unregister(Unregister) == :ok
    end
  end

  @systems [Idle, Interval, Run, Stop, UnsuccessfulUpdate, Update, Unregister, Cast, Purge, Call]
  defp register_test_systems(context) do
    Enum.each(@systems, &System.register/1)

    context
  end
end
