defmodule Exmud.SystemTest do
  alias Exmud.System
  use ExUnit.Case, async: true
  doctest Exmud.System

  describe "system tests" do
    setup [:setup_context]

    test "lifecycle", %{callback_module: system} = _context do
      if System.registered?(system) == false do
        System.register(system)
      end

      if System.running?(system) == false do
        System.start(system)
      end

      assert System.call(system, "foo") == "foo"
      assert System.cast(system, "foo") == system
      assert System.stop(system) == system
      assert System.running?(system) == false
      assert System.deregister(system) == system
      assert System.registered?(system) == false
    end
  end

  defp setup_context(_context) do
    %{callback_module: Exmud.System.Example}
  end
end


