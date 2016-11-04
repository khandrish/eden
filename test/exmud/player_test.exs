defmodule Exmud.PlayerTest do
  # alias Eden.Player
  # alias Eden.Registry
  # require Logger
  # use ExUnit.Case, async: true

  # describe "session interaction while player is disconnected:" do
  #   setup [:new_player]

  #   test "end_session", %{name: name} = context do
  #     assert Player.end_session(name) == :ok
  #   end

  #   test "session_exists?", %{name: name} = context do
  #     assert Player.session_exists?(name) == false
  #   end

  #   test "start_session", %{name: name} = context do
  #     assert Player.start_session(name) == :ok
  #   end
  # end

  # describe "session interaction while player is connected:" do
  #   setup [:new_player, :start_session]

  #   test "verify session process has registered itself", %{name: name} = context do
  #     assert Player.session_exists?(name) == true
  #   end

  #   test "session process unregisters as part of its terminate", %{name: name} = context do
  #     assert Player.end_session(name) == :ok
  #     assert Player.session_exists?(name) == false
  #   end

  #   test "use existing session if start_session/1 is called", %{name: name} = context do
  #     session = Registry.find_by_name(name)
  #     assert Player.start_session(name) == :ok
  #     assert Registry.find_by_name(name) == session
  #   end
  # end

  # defp new_player(_context) do
  #   %{name: Player.new(UUID.uuid4())}
  # end

  # defp start_session(%{name: name} = context) do
  #   Player.start_session(name)
  # end
end
