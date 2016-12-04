defmodule Exmud.GameObjectTest do
  alias Exmud.GameObject
  require Logger
  use ExUnit.Case, async: true

  describe "game object tests: " do
    setup [:create_new_game_object]

    test "delete tests", %{oid: oid} = _context do
      assert GameObject.delete(oid) == :ok
      assert GameObject.delete(0) == :ok
    end
  end

  defp create_new_game_object(_context) do
    key = UUID.uuid4()
    {:ok, oid} = GameObject.new(key)
    %{key: key, oid: oid}
  end
end
