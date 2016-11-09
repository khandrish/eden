defmodule Exmud.PlayerTest do
  alias Exmud.Player
  alias Exmud.Registry
  require Logger
  use ExUnit.Case, async: true

  describe "session interaction while player is disconnected: " do
    setup [:add_player]

    @tag pending:  true
    test "end_session", %{player: player} = _context do
      assert Player.end_session(player) == :ok
    end

    test "session_exists?", %{player: player} = _context do
      assert Player.has_active_session?(player) == false
    end

    test "start_session", %{player: player} = _context do
      assert Player.start_session(player) == player
    end
  end

  describe "session interaction while player is connected:" do
    setup [:add_player, :start_session]

    @tag pending: true
    test "verify session process has registered itself", %{player: player} = _context do
      assert Player.session_exists?(player) == true
    end

    @tag pending: true
    test "session process unregisters as part of its terminate", %{player: player} = _context do
      assert Player.end_session(player) == :ok
      assert Player.session_exists?(player) == false
    end

    @tag pending:  true
    test "use existing session if start_session/1 is called", %{player: player} = _context do
      session = Registry.find_by_name(player)
      assert Player.start_session(player) == :ok
      assert Registry.find_by_name(player) == session
    end
  end

  defp add_player(_context) do
    %{player: Player.add(UUID.uuid4())}
  end

  defp start_session(%{name: name} = _context) do
    Player.start_session(name)
  end
end
