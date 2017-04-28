defmodule Exmud.CommandSetTemplateTest do
  alias Ecto.UUID
  alias Exmud.CommandSetTemplate
  alias Exmud.CommandSetTemplateTest.ExampleCommandSetTemplate, as: ECST
  alias Exmud.Object
  require Logger
  use ExUnit.Case

  describe "command_set tests: " do
    setup [:create_new_game_object]

    @tag command_set_template: true
    test "command set template manipulation with commands" do
      command_set = CommandSetTemplate.new()
      command_set = CommandSetTemplate.add_command(command_set, :foo)
      assert command_set == %Exmud.CommandSetTemplate{commands: %MapSet{map: %{foo: true}}}
      assert CommandSetTemplate.has_command?(command_set, :bar) == false
      command_set = CommandSetTemplate.add_command(command_set, :bar)
      assert CommandSetTemplate.has_command?(command_set, :bar) == true
      assert command_set == %Exmud.CommandSetTemplate{commands: %MapSet{map: %{foo: true, bar: true}}}
      command_set = CommandSetTemplate.remove_command(command_set, :bar)
      assert CommandSetTemplate.has_command?(command_set, :bar) == false
      assert command_set == %Exmud.CommandSetTemplate{commands: %MapSet{map: %{foo: true}}}
    end

    @tag command_set_template: true
    test "command set manipulation with overrides" do
      command_set = CommandSetTemplate.new()
      assert CommandSetTemplate.has_override?(command_set, "foobar") == false
      command_set = CommandSetTemplate.add_override(command_set, "foobar", :replace)
      assert command_set == %Exmud.CommandSetTemplate{merge_type_overrides: %{"foobar" => :replace}}
      assert CommandSetTemplate.has_override?(command_set, "foobar") == true
      command_set = CommandSetTemplate.remove_override(command_set, "foobar")
      assert CommandSetTemplate.has_override?(command_set, "foobar") == false
    end

    @tag command_set_template: true
    test "other command set manipulation" do
      command_set =
        CommandSetTemplate.new()
        |> CommandSetTemplate.set_allow_duplicates(:true)
        |> CommandSetTemplate.set_merge_type(:replace)
        |> CommandSetTemplate.set_priority(10)

      assert command_set == %Exmud.CommandSetTemplate{allow_duplicates: :true,
                                                      merge_type: :replace,
                                                      priority: 10}
    end
  end

  defp create_new_game_object(context) do
    key = UUID.generate()
    {:ok, oid} = Object.new(key)
    context
    |> Map.put(:go_key, key)
    |> Map.put(:oid, oid)
  end
end

defmodule Exmud.CommandSetTemplateTest.ExampleCommandSetTemplate1 do
  @moduledoc """
  A barebones example of a command set template instance for testing.
  """

  @behaviour Exmud.CommandSetTemplate

  def init(_oid) do
    {:ok, Exmud.CommandSetTemplate.new()}
  end
end

defmodule Exmud.CommandSetTemplateTest.ExampleCommandSetTemplate2 do
  @moduledoc """
  A barebones example of a command set template instance for testing.
  """

  @behaviour Exmud.CommandSetTemplate

  def init(_oid) do
    {:ok, Exmud.CommandSetTemplate.new()}
  end
end

defmodule Exmud.CommandSetTemplateTest.ExampleCommandSetTemplate3 do
  @moduledoc """
  A barebones example of a command set template instance for testing.
  """

  @behaviour Exmud.CommandSetTemplate

  def init(_oid) do
    {:ok, Exmud.CommandSetTemplate.new()}
  end
end

defmodule Exmud.CommandSetTemplateTest.ExampleCommandSetTemplate4 do
  @moduledoc """
  A barebones example of a command set template instance for testing.
  """

  @behaviour Exmud.CommandSetTemplate

  def init(_oid) do
    {:ok, Exmud.CommandSetTemplate.new()}
  end
end