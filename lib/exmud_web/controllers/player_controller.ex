defmodule ExmudWeb.PlayerController do
  use ExmudWeb, :controller

  alias Exmud.Account

  def index(conn, _params) do
    players = Account.list_players()
    render(conn, "index.html", players: players)
  end

  def delete(conn, %{"id" => id}) do
    player = Account.get_player!(id)
    {:ok, _player} = Account.delete_player(player)

    conn
    |> put_flash(:info, "Player deleted successfully.")
    |> redirect(to: Routes.player_path(conn, :index))
  end
end
