defmodule Exmud.CommandSetTest do
  alias Ecto.UUID
  alias Exmud.CommandSet
  alias Exmud.CommandSetTemplate
  alias Exmud.CommandSetTest.ExampleCommandSet1, as: ECS1
  alias Exmud.CommandSetTest.ExampleCommandSet2, as: ECS2
  alias Exmud.CommandSetTest.ExampleCommandSet3, as: ECS3
  alias Exmud.CommandSetTest.ExampleCommandSet4, as: ECS4
  alias Exmud.CommandSetTest.ExampleCommand1, as: EC1
  alias Exmud.CommandSetTest.ExampleCommand2, as: EC2
  alias Exmud.CommandSetTest.ExampleCommand3, as: EC3
  alias Exmud.CommandSetTest.ExampleCommand4, as: EC4
  alias Exmud.CommandTemplate
  alias Exmud.Object
  require Logger
  use ExUnit.Case

  describe "command_set tests: " do
    setup [:create_low_priority_command_set, :create_command_set, :create_high_priority_command_set]

    @tag command_set: true
    test "command set union merge tests", %{lpcs: lpcs, cs: cs, hpcs: hpcs} = _contex do
      final_command_set = CommandSet.merge(cs, lpcs)
      assert final_command_set.commands == cs.commands
      Enum.find(MapSet.to_list(final_command_set.commands), &(&1.object == lpcs.object)) == nil

      final_command_set = CommandSet.merge(cs, hpcs)
      assert Enum.find(MapSet.to_list(final_command_set.commands), &(&1.object == hpcs.object)) != nil
      assert final_command_set.callback_module == ECS3

      hpcs = %{hpcs | allow_duplicates: :true}
      final_command_set = CommandSet.merge(cs, hpcs)
      assert Enum.find(MapSet.to_list(final_command_set.commands), &(&1.object == cs.object)) != nil
      assert Enum.find(MapSet.to_list(final_command_set.commands), &(&1.object == hpcs.object)) != nil
    end

    @tag command_set: true
    test "command set intersect merge tests", %{lpcs: lpcs, cs: cs, hpcs: hpcs} = _contex do
      hpcs = %{hpcs | merge_type: :intersect}
      final_command_set = CommandSet.merge(cs, hpcs)
      assert Enum.find(MapSet.to_list(final_command_set.commands), &(&1.object == lpcs.object)) == nil
      assert Enum.find(MapSet.to_list(final_command_set.commands), &(&1.object == hpcs.object)) != nil

      hpcs = %{hpcs | allow_duplicates: :true}
      final_command_set = CommandSet.merge(cs, hpcs)
      assert Enum.find(MapSet.to_list(final_command_set.commands), &(&1.object == cs.object)) != nil
      assert Enum.find(MapSet.to_list(final_command_set.commands), &(&1.object == hpcs.object)) != nil
    end

    @tag command_set: true
    test "command set replace merge via override test", %{lpcs: lpcs, cs: cs, hpcs: hpcs} = _contex do
      hpcs = %{hpcs | merge_type_overrides: Map.put(%{}, ECS2, :replace)}

      final_command_set = CommandSet.merge(hpcs, lpcs)
      assert final_command_set == hpcs
    end

    @tag command_set: true
    test "command set remove merge test", %{lpcs: lpcs, cs: cs, hpcs: hpcs} = _contex do
      hpcs = %{hpcs | merge_type: :remove}

      final_command_set = CommandSet.merge(cs, hpcs)
      assert MapSet.size(final_command_set.commands) == 2
    end
  end

  defp create_low_priority_command_set(context) do
    low_priority_command_set =
      %CommandSetTemplate{
        allow_duplicates: false,
        callback_module: ECS2,
        commands: MapSet.new([EC1, EC2]),
        merge_type: :union,
        merge_type_overrides: %{},
        object: UUID.generate(),
        priority: -1
      }
      |> CommandSet.initialize_commands()

    Map.put(context, :lpcs, low_priority_command_set)
  end

  defp create_command_set(context) do
    command_set =
      %CommandSetTemplate{
        allow_duplicates: false,
        callback_module: ECS1,
        commands: MapSet.new([EC1, EC2, EC3, EC4]),
        merge_type: :union,
        merge_type_overrides: %{},
        object: UUID.generate(),
        priority: 0
      }
      |> CommandSet.initialize_commands()

    Map.put(context, :cs, command_set)
  end

  defp create_high_priority_command_set(context) do
    high_priority_command_set =
      %CommandSetTemplate{
        allow_duplicates: false,
        callback_module: ECS3,
        commands: MapSet.new([EC3, EC4]),
        merge_type: :union,
        merge_type_overrides: Map.put(%{}, ECS2, :replace),
        object: UUID.generate(),
        priority: 1
      }
      |> CommandSet.initialize_commands()

    Map.put(context, :hpcs, high_priority_command_set)
  end
end

defmodule Exmud.CommandSetTest.ExampleCommandSet1 do
end

defmodule Exmud.CommandSetTest.ExampleCommandSet2 do
end

defmodule Exmud.CommandSetTest.ExampleCommandSet3 do
end

defmodule Exmud.CommandSetTest.ExampleCommandSet4 do
end

defmodule Exmud.CommandSetTest.ExampleCommand1 do
  @moduledoc """
  A barebones example of a command template instance for testing.
  """

  alias Exmud.CommandTemplate
  @behaviour Exmud.Command

  def init(command_template) do
    command_template
    |> CommandTemplate.set_key("move")
    |> CommandTemplate.add_alias("go")
    |> CommandTemplate.add_alias("run")
    |> CommandTemplate.add_alias("walk")
  end

  def run(_), do: {:ok, nil}
  def parse(_), do: {:ok, nil}
end

defmodule Exmud.CommandSetTest.ExampleCommand2 do
  @moduledoc """
  A barebones example of a command template instance for testing.
  """

  alias Exmud.CommandTemplate
  @behaviour Exmud.Command

  def init(command_template) do
    command_template
    |> CommandTemplate.set_key("look")
    |> CommandTemplate.add_alias("gaze")
    |> CommandTemplate.add_alias("examine")
    |> CommandTemplate.add_alias("peer")
  end

  def run(_), do: {:ok, nil}
  def parse(_), do: {:ok, nil}
end

defmodule Exmud.CommandSetTest.ExampleCommand3 do
  @moduledoc """
  A barebones example of a command template instance for testing.
  """

  alias Exmud.CommandTemplate
  @behaviour Exmud.Command

  def init(command_template) do
    command_template
    |> CommandTemplate.set_key("say")
    |> CommandTemplate.add_alias("speak")
  end

  def run(_), do: {:ok, nil}
  def parse(_), do: {:ok, nil}
end

defmodule Exmud.CommandSetTest.ExampleCommand4 do
  @moduledoc """
  A barebones example of a command template instance for testing.
  """

  alias Exmud.CommandTemplate
  @behaviour Exmud.Command

  def init(command_template) do
    command_template
    |> CommandTemplate.set_key("climb")
  end

  def run(_), do: {:ok, nil}
  def parse(_), do: {:ok, nil}
end