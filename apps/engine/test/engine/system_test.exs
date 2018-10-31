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

  describe "system" do

    test "with successful start" do
      assert System.initialize( Idle ) == :ok
      assert System.start( Idle ) == :ok
      assert System.running?( Idle ) == true
      assert System.stop( Idle ) == :ok
      assert System.running?( Idle ) == false
      assert System.start( Idle ) == :ok
    end

    test "with running check on nonexisting system" do
      assert System.running?( :foo ) == false
    end

    test "with getting state" do
      assert System.initialize( Interval ) == :ok
      assert System.start( Interval ) == :ok
      assert System.get_state( Interval ) == { :ok, nil }
      assert System.stop( Interval ) == :ok
      assert System.get_state( Interval ) == { :ok, nil }
    end

    test "with successful stop" do
      assert System.initialize( Stop ) == :ok
      assert System.start( Stop ) == :ok
      assert System.stop( Stop ) == :ok
    end

    test "with error while stopping" do
      assert System.stop( "foo" ) == { :error, :no_such_system }
    end

    test "with successful run" do
      assert System.initialize( Run ) == :ok
      assert System.start( Run ) == :ok
      assert System.run( Run ) == :ok
    end

    test "with successful call" do
      assert System.initialize( Call ) == :ok
      assert System.start( Call ) == :ok
      assert System.call( Call, "foo" ) == { :ok, "foo" }
      assert System.stop( Call ) == :ok
    end

    test "with successful cast" do
      assert System.initialize( Cast ) == :ok
      assert System.start( Cast ) == :ok
      assert System.cast( Cast, "foo" ) == :ok
      assert System.stop( Cast ) == :ok
    end

    test "with successful purge" do
      assert System.initialize( Purge ) == :ok
      assert System.start( Purge ) == :ok
      assert System.purge( Purge ) == :ok
      assert System.stop( Purge ) == :ok
    end

    test "with error while purging" do
      assert System.purge( :foo ) == { :error, :no_such_system }
    end

    test "with successful update" do
      assert System.initialize( Update ) == :ok
      assert System.start( Update ) == :ok
      assert System.stop( Update ) == :ok
      assert System.update( Update, :bar ) == :ok
      assert System.get_state( Update ) == { :ok, :bar }
    end

    test "with unsuccessful update" do
      assert System.initialize( UnsuccessfulUpdate ) == :ok
      assert System.start( UnsuccessfulUpdate ) == :ok
      assert System.stop( UnsuccessfulUpdate ) == :ok
      assert System.update( UnsuccessfulUpdate, :bar ) == :ok
      assert System.get_state( UnsuccessfulUpdate ) == { :ok, :bar }
    end
  end
end
