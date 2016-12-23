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
    test "command set manipulation with commands" do
      command_set = CommandSet.new()
      command_set = CommandSet.add_command(command_set, :foo)
      assert command_set == %Exmud.CommandSet{commands: %MapSet{map: %{foo: true}}}
      assert CommandSet.has_command?(command_set, :bar) == false
      command_set = CommandSet.add_command(command_set, :bar)
      assert CommandSet.has_command?(command_set, :bar) == true
      assert command_set == %Exmud.CommandSet{commands: %MapSet{map: %{foo: true, bar: true}}}
      command_set = CommandSet.remove_command(command_set, :bar)
      assert CommandSet.has_command?(command_set, :bar) == false
      assert command_set == %Exmud.CommandSet{commands: %MapSet{map: %{foo: true}}}
    end
    
    @tag command_set: true
    test "command set manipulation with overrides" do
      command_set = CommandSet.new()
      assert CommandSet.has_override?(command_set, "foobar") == false
      command_set = CommandSet.add_override(command_set, "foobar", :replace)
      assert command_set == %Exmud.CommandSet{merge_type_overrides: %{"foobar" => :replace}}
      assert CommandSet.has_override?(command_set, "foobar") == true
      command_set = CommandSet.remove_override(command_set, "foobar")
      assert CommandSet.has_override?(command_set, "foobar") == false
    end
    
    @tag command_set: true
    @tag pending: true
    # TODO: Create the command module so a test commands can be used here
    test "command set merge tests" do
      _command_set =
        CommandSet.new()
        |> CommandSet.add_command(:foo)
        |> CommandSet.add_command(:bar)
        
      _low_priority_command_set =
        CommandSet.new()
        |> CommandSet.set_priority(-1)
        |> CommandSet.add_command(:foo)
        |> CommandSet.add_command(:low_foo)
        |> CommandSet.add_command(:low_bar)
      
      _high_priority_command_set =
        CommandSet.new()
        |> CommandSet.set_priority(1)
        |> CommandSet.add_command(:bar)
        |> CommandSet.add_command(:high_foo)
        |> CommandSet.add_command(:high_bar)
        
        
    end
  end

  defp create_new_game_object(context) do
    key = UUID.generate()
    {:ok, oid} = GameObject.new(key)
    context
    |> Map.put(:go_key, key)
    |> Map.put(:oid, oid)
  end
end

defmodule Exmud.CommandSetTest.ExampleCommandSet do
  @moduledoc """
  A barebones example of a command set for testing.
  """
  
  @behaviour Exmud.CommandSet
  
  def init(_oid) do
    {:ok, Exmud.CommandSet.new()}
  end
end