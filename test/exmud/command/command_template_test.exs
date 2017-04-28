defmodule Exmud.CommandTemplateTest do
  alias Ecto.UUID
  alias Exmud.CommandTemplate
  alias Exmud.Object
  require Logger
  use ExUnit.Case

  describe "Command template tests: " do
    setup [:create_new_game_object]

    @tag command_template: true
    test "Command template manipulation with aliases" do
      template = CommandTemplate.new()
      template = CommandTemplate.add_alias(template, :foo)
      assert template == %Exmud.CommandTemplate{aliases: %MapSet{map: %{foo: true}}}
      assert CommandTemplate.has_alias?(template, :bar) == false
      template = CommandTemplate.add_alias(template, :bar)
      assert CommandTemplate.has_alias?(template, :bar) == true
      assert template == %Exmud.CommandTemplate{aliases: %MapSet{map: %{foo: true, bar: true}}}
      template = CommandTemplate.remove_alias(template, :bar)
      assert CommandTemplate.has_alias?(template, :bar) == false
      assert template == %Exmud.CommandTemplate{aliases: %MapSet{map: %{foo: true}}}
    end

    @tag command_template: true
    test "Command template setters" do
      template =
        CommandTemplate.new()
        |> CommandTemplate.set_callback_module(__MODULE__)
        |> CommandTemplate.set_auto_help(:false)
        |> CommandTemplate.set_help_category("Foobar")
        |> CommandTemplate.set_key("bar")
      assert template == %CommandTemplate{
        callback_module: __MODULE__,
        auto_help: :false,
        help_category: "Foobar",
        key: "bar"
      }
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