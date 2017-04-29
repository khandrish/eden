defmodule Exmud.SystemTest do
  alias Exmud.Registry
  alias Exmud.System
  use ExUnit.Case # Can't be async otherwise it won't load the test system

  describe "system tests: " do
    setup [:do_setup]

    @tag system: true
    test "regular lifecycle", %{es: callback_module, es_key: key} = _context do
      assert System.start(key, callback_module) == :ok
      assert System.start(key, callback_module) == {:error, :already_started} # Can't start two of the same key
      assert System.running?(key) == true

      case Registry.read_key(key, "system") do
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

    @tag system: true
    test "idle lifecycle", %{ies: callback_module, ies_key: key} = _context do
      assert System.start(key, callback_module) == :ok
      assert System.running?(key) == true
      assert System.call(key, "foo") == "foo"
      assert System.stop(key) == :ok
    end

    @tag system: true
    test "calls with invalid system", _context do
      assert System.stop("foo") == {:error, :no_such_system}
      assert System.call("foo", "foo") == {:error, :no_such_system}
      assert System.cast("foo", "foo") == {:error, :no_such_system}
      assert System.purge("foo") == {:error, :no_such_system}
    end
  end

  defp do_setup(_context) do
    %{es: Exmud.SystemTest.ExampleSystem, es_key: "ExampleSystem",
      ies: Exmud.SystemTest.ExampleSystemIdle, ies_key: "IdleExampleSystem"}
  end
end

defmodule Exmud.SystemTest.ExampleSystem do
  @moduledoc """
  A barebones example of a system for testing.
  """

  use Exmud.System

  def start(state) do
    {state, 50}
  end

  def run(state) do
    {state, 50}
  end
end

defmodule Exmud.SystemTest.ExampleSystemIdle do
  @moduledoc """
  A barebones example of a system for testing.
  """

  use Exmud.System

  def handle_message(message, state) do
    {message, state, :never}
  end
end
