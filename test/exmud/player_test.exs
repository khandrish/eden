defmodule Exmud.PlayerTest do
  alias Exmud.Player
  alias Exmud.Repo
  require Logger
  use ExUnit.Case, async: true

  describe "player lifecycle tests: " do
    setup [:add_player]

    test "player lifecycle", %{player: player} = _context do
      assert Player.exists?(player) == true
      assert Player.remove(player) == :ok
      assert Player.exists?(player) == false
      assert Player.remove(player) == :ok
      assert Player.add(player) == :ok
      assert Player.exists?(player) == true
      assert Player.add(player) == {:error, :key_in_use}
    end
  end

  describe "player session tests: " do
    setup [:add_player]

    test "session lifecycle", %{player: player} = _context do
      assert Player.has_active_session?(player) == false
      assert Player.stop_session(player) == {:error, :no_session_active}
      assert Player.start_session(player) == :ok
      assert Player.has_active_session?(player) == true
      me = self()
      assert Player.stream_session_output(player, fn(message) -> send(me, {:message, message}) end) == :ok
      assert Player.send_output(player, :foo) == :ok
      assert (receive do
        {:message, message} -> message
        after 500 -> :error
      end) == :foo
      assert Player.stop_session(player) == :ok
      assert Player.has_active_session?(player) == false
    end
  end

  describe "player data tests: " do
    setup [:add_player]

    test "data lifecycle", %{player: player} = _context do
      assert Player.has_key?(player, "foo") == false
      assert Player.put_key(player, "foo", :bar) == :ok
      assert Player.has_key?(player, "foo") == true
      assert Player.get_key(player, "foo") == :bar
      assert Player.delete_key(player, "foo") == :bar
      assert Player.has_key?(player, "foo") == false
      assert Player.delete_key(player, "foobar") == {:ok, nil}
      assert Player.put_key("invalid player", "foo", :bar) == {:error, :no_such_player}
      assert Player.put_key(player, :invalid_key, :bar) == {:error, [key: {"is invalid", [type: :string]}]}
      assert Player.has_key?("invalid player", "foo") == false
      assert Player.delete_key("invalid player", "foobar") == {:ok, nil}
    end
  end

  defp add_player(_context) do
    key = UUID.uuid4()
    :ok = Player.add(key)
    %{player: key}
  end
end
