defmodule Exmud.CommandSetTest do
  alias Ecto.UUID
  alias Exmud.CommandSet
  alias Exmud.CommandSetTest.ExampleCommandSet, as: EC
  alias Exmud.GameObject
  require Logger
  use ExUnit.Case

  describe "command_set tests: " do
    setup [:create_new_game_object]
    
    @tag command_set: true
    test "engine registration" do
      command_set = UUID.generate()
      command_set2 = UUID.generate()
      assert CommandSet.registered?(command_set) == false
      assert CommandSet.register(command_set, EC) == :ok
      assert CommandSet.register(command_set2, EC, true) == :ok
      assert CommandSet.get(command_set) == {:ok, %Exmud.CommandSet{}}
      assert CommandSet.get(command_set2) == {:ok, %Exmud.CommandSet{}}
      assert CommandSet.registered?(command_set) == true
      assert CommandSet.unregister(command_set) == :ok
      assert CommandSet.registered?(command_set) == false
    end
    
    @tag command_set: true
    test "lifecycle", %{oid: oid} = _context do
      command_set = UUID.generate()
      command_set2 = UUID.generate()
      assert CommandSet.register(command_set, EC) == :ok
      assert CommandSet.has?(oid, command_set) == {:ok, false}
      assert CommandSet.add(oid, command_set) == :ok
      assert CommandSet.add(oid, command_set2) == :ok
      assert CommandSet.list(command_set) == [oid]
      assert CommandSet.list([command_set, command_set2]) == [oid]
      assert CommandSet.has?(oid, command_set) == {:ok, true}
      assert CommandSet.delete(oid, command_set) == :ok
      assert CommandSet.has?(oid, command_set) == {:ok, false}
    end
    
    @tag command_set: true
    test "invalid cases" do
      assert CommandSet.has?(0, "foo") == {:ok, false}
      assert CommandSet.add(0, "foo") == {:error, :no_such_game_object}
      assert CommandSet.delete(0, "foo") == {:error, :no_such_command_set}
    end
  end

  defp create_new_game_object(_context) do
    key = UUID.generate()
    {:ok, oid} = GameObject.new(key)
    %{key: key, oid: oid}
  end
end

defmodule Exmud.CommandSetTest.ExampleCommandSet do
  @moduledoc """
  A barebones example of a command set for testing.
  """
  
  @behavior Exmud.CommandSet
  
  def init(_oid) do
    {:ok, Exmud.CommandSet.new()}
  end
end