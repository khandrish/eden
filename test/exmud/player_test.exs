defmodule Exmud.PlayerTest do
  alias Ecto.UUID
  alias Exmud.Player
  require Logger
  use ExUnit.Case, async: true

  describe "player lifecycle tests: " do
    setup [:add_player]

    @tag player: true
    test "player lifecycle", %{player: player} = _context do
      assert Player.exists?(player) == true
      assert Player.remove(player) == :ok
      assert Player.exists?(player) == false
      assert Player.remove(player) == {:error, :no_such_player}
      assert Player.add(player) == :ok
      assert Player.exists?(player) == true
      assert Player.add(player) == {:error, :player_already_exists}
    end
  end

  describe "player session tests: " do
    setup [:add_player]

    @tag player: true
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

    @tag player: true
    test "data lifecycle", %{player: player} = _context do
      assert Player.has_attribute?(player, "foo") == {:ok, false}
      assert Player.add_attribute(player, "foo", :bar) == :ok
      assert Player.has_attribute?(player, "foo") == {:ok, true}
      assert Player.get_attribute(player, "foo") == {:ok, :bar}
      assert Player.remove_attribute(player, "foo") == :ok
      assert Player.has_attribute?(player, "foo") == {:ok, false}
    end
    
    @tag player: true
    test "invalid data tests", %{player: player} = _context do
      assert Player.has_attribute?("invalid player", "foo") == {:error, :no_such_player}
      assert Player.add_attribute("invalid player", "foo", :bar) == {:error, :no_such_player}
      assert Player.remove_attribute("invalid player", "foo") == {:error, :no_such_player}
      assert Player.get_attribute("invalid player", "foo") == {:error, :no_such_player}
      assert Player.remove_attribute(player, "foobar") == {:error, :no_such_attribute}
      assert Player.add_attribute("invalid player", "foo", :bar) == {:error, :no_such_player}
      assert Player.add_attribute(player, :invalid_attribute, :bar) == {:error, [key: {"is invalid", [type: :string, validation: :cast]}]}
      assert Player.has_attribute?("invalid player", "foo") == {:error, :no_such_player}
    end
  end

  defp add_player(_context) do
    attribute = UUID.generate()
    :ok = Player.add(attribute)
    %{player: attribute}
  end
end
