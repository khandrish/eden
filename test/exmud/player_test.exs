defmodule Exmud.PlayerTest do
  alias Exmud.Player
  require Logger
  use ExUnit.Case, async: true

  describe "player lifecycle tests: " do
    setup [:add_player]

    test "player lifecycle", %{player: player} = _context do
      assert Player.exists?(player) == true
      assert Player.remove(player) == player
      assert Player.exists?(player) == false
      assert Player.remove(player) == player
      assert Player.add(player) == player
      assert Player.exists?(player) == true
      assert Player.add(player) == player
    end
  end

  describe "player session tests: " do
    setup [:add_player]

    test "session lifecycle", %{player: player} = _context do
      assert Player.has_active_session?(player) == false
      assert Player.stop_session(player) == player
      assert Player.start_session(player) == player
      assert Player.has_active_session?(player) == true
      assert Player.stop_session(player) == player
      assert Player.has_active_session?(player) == false
    end
  end

  describe "player data tests: " do
    setup [:add_player]

    test "data lifecycle", %{player: player} = _context do
      assert Player.has_key?(player, :foo) == false
      assert Player.put_key(player, :foo, :bar) == player
      assert Player.has_key?(player, :foo) == true
      assert Player.get_key(player, :foo) == :bar
      assert Player.delete_key(player, :foo) == player
      assert Player.has_key?(player, :foo) == false
    end
  end

  defp add_player(_context) do
    %{player: Player.add(UUID.uuid4())}
  end
end
