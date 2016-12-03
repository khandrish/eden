defmodule Exmud.SystemTest do
  alias Exmud.System
  use ExUnit.Case # Can't be async otherwise it won't load the test system
  doctest Exmud.System

  describe "system tests: " do
    setup [:do_setup]

    test "lifecycle", %{callback_module: callback_module, name: name} = _context do
      assert System.start(name, callback_module) == {:ok, name}
      assert System.start(name, callback_module) == {:error, :already_started} # Can't start two of the same name
      assert System.running?(name) == true
      assert System.call(name, "foo") == "foo"
      assert System.cast(name, "foo") == :ok
      assert System.stop(name) == :ok
      assert System.running?(name) == false
      assert System.start(name, callback_module) == {:ok, name} # Start again just to make sure everything was shutdown/deregistered
      assert System.stop(name) == :ok
      assert System.running?(name) == false
      assert System.purge(name) == {:ok, %{}}
    end
    
    test "calls with invalid system", _context do
      assert System.stop("foo") == {:error, :no_such_system}
      assert System.call("foo", "foo") == {:error, :no_such_system}
      assert System.cast("foo", "foo") == {:error, :no_such_system}
      assert System.purge("foo") == {:error, :no_such_system}
    end
  end

  defp do_setup(_context) do
    %{callback_module: Exmud.SystemTest.ExampleSystem, name: "ExampleSystem"}
  end
end

defmodule Exmud.SystemTest.ExampleSystem do
  @moduledoc """
  A barebones example of a system for testing.
  """
  
  use Exmud.System
end



