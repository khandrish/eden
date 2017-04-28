defmodule Exmud.SystemTest do
  alias Exmud.System
  use ExUnit.Case # Can't be async otherwise it won't load the test system
  doctest Exmud.System

  describe "system tests: " do
    setup [:do_setup]


    test "lifecycle", %{callback_module: callback_module, key: key} = _context do
      assert System.start(key, callback_module) == :ok
      assert System.start(key, callback_module) == {:error, :already_started} # Can't start two of the same key
      assert System.running?(key) == true
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

    test "calls with invalid system", _context do
      assert System.stop("foo") == {:error, :no_such_system}
      assert System.call("foo", "foo") == {:error, :no_such_system}
      assert System.cast("foo", "foo") == {:error, :no_such_system}
      assert System.purge("foo") == {:error, :no_such_system}
    end
  end

  defp do_setup(_context) do
    %{callback_module: Exmud.SystemTest.ExampleSystem, key: "ExampleSystem"}
  end
end

defmodule Exmud.SystemTest.ExampleSystem do
  @moduledoc """
  A barebones example of a system for testing.
  """

  use Exmud.System
end
