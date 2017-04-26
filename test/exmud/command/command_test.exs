defmodule Exmud.CommandTest do
  alias Ecto.UUID
  alias Exmud.Command
  alias Exmud.Object
  require Logger
  use ExUnit.Case

  describe "command tests: " do
    setup [:create_new_game_object]

    @tag command: true
    test "command lifecycle" do
      args = UUID.generate()
      object = UUID.generate()
      match_string = UUID.generate()
      subject = UUID.generate()
      command = Command.new()
        |> Command.set_args(args)
        |> Command.set_object(object)
        |> Command.set_match_string(match_string)
        |> Command.set_subject(subject)

      assert Command.get_args(command) == args
      assert Command.get_object(command) == object
      assert Command.get_match_string(command) == match_string
      assert Command.get_subject(command) == subject
    end
  end

  defp create_new_game_object(context) do
    key = UUID.generate()
    {:ok, oid} = Object.new(key)
    context
    |> Map.put(:object_key, key)
    |> Map.put(:oid, oid)
  end
end
