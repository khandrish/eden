defmodule Exmud.Engine.SystemTest do
  alias Exmud.Engine.Cache
  alias Exmud.Engine.System
  use Exmud.Engine.Test.DBTestCase

  describe "system tests: " do
    setup [:do_setup]

    @tag engine: true
    @tag system: true
    test "regular lifecycle", %{es: callback_module, es_key: key} = _context do
      assert System.start(key, callback_module) == :ok
      assert System.start(key, callback_module) == {:error, :already_started} # Can't start two of the same key
      assert System.running?(key) == true

      case Cache.get(key, "system") do
        {:ok, pid} -> send(pid, :run)
      end

      assert System.get_state(key) != nil
      assert System.call(key, "foo") == "foo"
      assert System.cast(key, "foo") == :ok
      assert System.stop(key) == :ok
      assert System.running?(key) == false
      assert System.start(key, callback_module) == :ok # Start again just to make sure everything was shutdown/deregistered
      assert System.stop(key) == :ok
      assert System.running?(key) == false
      assert System.purge(key) == {:ok, %{}}
    end

    @tag engine: true
    @tag system: true
    test "idle lifecycle", %{ies: callback_module, ies_key: key} = _context do
      assert System.start(key, callback_module) == :ok
      assert System.running?(key) == true
      assert System.call(key, "foo") == "foo"
      assert System.stop(key) == :ok
    end

    @tag engine: true
    @tag system: true
    test "calls with invalid system", _context do
      assert System.stop("foo") == {:error, :system_not_running}
      assert System.call("foo", "foo") == {:error, :system_not_running}
      assert System.cast("foo", "foo") == {:error, :system_not_running}
      assert System.purge("foo") == {:error, :no_such_system}
    end
  end

  defp do_setup(_context) do
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
    {state, 50}
  end

  def run(state) do
    {state, 50}
  end
end

defmodule Exmud.Engine.SystemTest.ExampleSystemIdle do
  @moduledoc """
  A barebones example of a system for testing.
  """

  use Exmud.Engine.System

  def handle_message(message, state) do
    {message, state, :never}
  end

  def run(state) do
    {state, :never}
  end
end