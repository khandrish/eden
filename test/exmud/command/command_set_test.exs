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
