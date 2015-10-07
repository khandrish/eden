defmodule Eden.Plug.Authenticated do
  @moduledoc """
    Authenticated plug can be used ensure an action can only be triggered by
    players that are authenticated.
  """
  import Plug.Conn

  alias Eden.Player
  alias Eden.Repo

  def init(default) do
    default
  end

  def call(conn, _opts) do
    if player = get_player(conn) do
      assign(conn, :current_player, player)
    else
      auth_error!(conn)
    end
  end

  def get_player(conn) do
    case conn.assigns[:current_player] do
      nil      -> fetch_player(conn)
      player     -> player
    end
  end

  defp fetch_player(conn) do
    case get_session(conn, :current_player) do
      nil -> nil
      player_id -> find_player(player_id)
    end
  end

  defp find_player(id) do
    case Repo.get(Player, id) do
      nil -> nil
      player -> player
    end
  end

  defp auth_error!(conn) do
    conn
    |> halt
    |> send_resp(:unauthorized, "")
  end
end