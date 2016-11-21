defmodule Exmud.SystemTest do
  alias Exmud.System
  use ExUnit.Case, async: true
  doctest Exmud.System

  describe "system tests" do
    setup [:setup_context]

    test "lifecycle", %{callback_module: system} = _context do

      assert System.start(system) == system
      assert System.start(system) == {:error, :already_started} # Can't start two of the same name
      assert System.start({:foobar, system}) == :foobar # Can start same system with custom name, though
      assert System.stop(:foobar) == :foobar
      assert System.running?(system) == true
      assert System.state(system) == %{}
      assert System.call(system, "foo") == "foo"
      assert System.cast(system, "foo") == system
      assert System.stop(system) == system
      assert System.running?(system) == false
      assert System.start(system) == system # Start again just to make sure everything was shutdown/deregistered
      assert System.stop(system) == system
      assert System.running?(system) == false
      assert System.state(system) == %{} # Check state while system stopped
      assert System.purge(system) == %{} # Current state is returned on purge
      assert System.state(system) == nil
    end
  end

  defp setup_context(_context) do
    %{callback_module: Exmud.SystemTest.ExampleSystem}
  end
end

defmodule Exmud.SystemTest.ExampleSystem do
  @moduledoc """
  A barebones example of a system for testing.
  """
  
  use Exmud.System
end



