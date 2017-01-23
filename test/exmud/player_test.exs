defmodule Exmud.PlayerTest do
  alias Ecto.UUID
  alias Exmud.Player
  require Logger
  use ExUnit.Case, async: true

  describe "player lifecycle tests: " do
    setup [:add_player]

    @tag player: true
    test "player lifecycle", %{key: key, oid: oid} = _context do
      assert Player.exists?(key) == true
      assert Player.remove(key) == {:ok, key}
      assert Player.exists?(key) == false
      assert Player.remove(key) == {:error, :no_such_player}
      assert {:ok, _} = Player.add(key)
      assert Player.exists?(key) == true
      assert Player.add(key) == {:error, :player_already_exists}
    end
  end

  describe "player session tests: " do
    setup [:add_player]

    @tag player: true
    test "session lifecycle", %{key: key} = _context do
      assert Player.has_active_session?(key) == false
      assert Player.stop_session(key) == {:error, :no_session_active}
      assert Player.start_session(key) == :ok
      assert Player.has_active_session?(key) == true
      me = self()
      assert Player.stream_session_output(key, fn(message) -> send(me, {:message, message}) end) == :ok
      assert Player.send_output(key, :foo) == :ok
      assert (receive do
        {:message, message} -> message
        after 500 -> :error
      end) == :foo
      assert Player.stop_session(key) == :ok
      assert Player.has_active_session?(key) == false
    end
  end

  describe "player data tests: " do
    setup [:add_player]

    @tag player: true
    test "data lifecycle", %{key: key} = _context do
      assert Player.has_attribute?(key, "foo") == {:ok, false}
      assert Player.add_attribute(key, "foo", :bar) == :ok
      assert Player.has_attribute?(key, "foo") == {:ok, true}
      assert Player.get_attribute(key, "foo") == {:ok, :bar}
      assert Player.remove_attribute(key, "foo") == :ok
      assert Player.has_attribute?(key, "foo") == {:ok, false}
    end

    @tag player: true
    test "invalid data tests", %{key: key} = _context do
      assert Player.has_attribute?("invalid player", "foo") == {:error, :no_such_player}
      assert Player.add_attribute("invalid player", "foo", :bar) == {:error, :no_such_player}
      assert Player.remove_attribute("invalid player", "foo") == {:error, :no_such_player}
      assert Player.get_attribute("invalid player", "foo") == {:error, :no_such_player}
      assert Player.remove_attribute(key, "foobar") == {:error, :no_such_attribute}
      assert Player.add_attribute("invalid player", "foo", :bar) == {:error, :no_such_player}
      assert Player.add_attribute(key, :invalid_attribute, :bar) == {:error, [key: {"is invalid", [type: :string, validation: :cast]}]}
      assert Player.has_attribute?("invalid player", "foo") == {:error, :no_such_player}
    end
  end

  defp add_player(_context) do
    key = UUID.generate()
    {:ok, oid} = Player.add(key)
    %{key: key, oid: oid}
  end
end
