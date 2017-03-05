defmodule Exmud.PlayerTest do
  alias Ecto.UUID
  alias Exmud.Player
  alias Exmud.Repo
  require Logger
  use ExUnit.Case, async: true

  doctest Exmud.Player

  describe "Standard Ecto usage for player tests: " do
    setup [:add_player]

    @tag player: true
    test "player lifecycle", %{key: key, oid: oid} = _context do
      assert Player.exists(key) == {:ok, true}
      assert Player.remove(key) == {:ok, oid}
      assert Player.exists(key) == {:ok, false}
      assert Player.remove(key) == {:error, :no_such_player}
      assert {:ok, oid} = Player.add(key)
      assert Player.exists(key) == {:ok, true}
      assert Player.which(key) == {:ok, oid}
      assert Player.add(key) == {:error, :player_already_exists}
    end

    @tag player: true
    test "invalid data", %{key: key} = _context do
      assert_raise Ecto.Query.CastError, fn ->
        assert Player.add(1)
      end
    end
  end

  describe "Multi Ecto usage for player tests: " do
    setup [:add_player_multi]

    @tag player: true
    test "attribute lifecycle", %{key: key, multi: multi, oid: oid} = _context do
      attribute = UUID.generate()
      attribute2 = UUID.generate()
      assert Repo.transaction(Player.exists(multi, "exists", key)) == {:ok, %{"exists" => true}}
      assert Repo.transaction(Player.remove(multi, "remove", key)) == {:ok, %{"remove" => oid}}
      assert Repo.transaction(Player.exists(multi, "exists", key)) == {:ok, %{"exists" => false}}
      assert Repo.transaction(Player.remove(multi, "remove", key)) == {:error, "remove", :no_such_player, %{}}
      assert {:ok, %{"add" => noid}} = Repo.transaction(Player.add(multi, "add", key))
      assert Repo.transaction(Player.exists(multi, "exists", key)) == {:ok, %{"exists" => true}}
      assert Repo.transaction(Player.which(multi, "which", key)) == {:ok, %{"which" => noid}}
      assert Repo.transaction(Player.add(multi, "add", key)) == {:error, "add", :player_already_exists, %{}}
    end
  end

  defp add_player(_context) do
    key = UUID.generate()
    {:ok, oid} = Player.add(key)
    %{key: key, oid: oid}
  end

  defp add_player_multi(_context) do
    key = UUID.generate()
    {:ok, results} = Ecto.Multi.new()
    |> Player.add("add", key)
    |> Repo.transaction()

    %{key: key, multi: Ecto.Multi.new(), oid: results["add"]}
  end
end
