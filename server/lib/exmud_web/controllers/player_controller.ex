defmodule ExmudWeb.PlayerController do
  use ExmudWeb, :controller

  alias Exmud.Account
  alias Exmud.Account.Player

  action_fallback ExmudWeb.FallbackController

  def index(conn, params) do
    page = Map.get(params, "page", 0)
    page_size = Map.get(params, "pageSize", 10)
    players = Account.list_players(page, page_size)
    render(conn, "index.json", players: players)
  end

  def create(conn, %{"player" => player_params}) do
    with {:ok, %Player{} = player} <- Account.create_player(player_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.player_path(conn, :show, player))
      |> render("show.json", player: player)
    end
  end

  def show(conn, %{"id" => id}) do
    player = Account.get_player!(id)
    render(conn, "show.json", player: player)
  end

  def update(conn, %{"id" => id, "player" => player_params}) do
    player = Account.get_player!(id)

    with {:ok, %Player{} = player} <- Account.update_player(player, player_params) do
      render(conn, "show.json", player: player)
    end
  end

  def delete(conn, %{"id" => id}) do
    player = Account.get_player!(id)

    with {:ok, %Player{}} <- Account.delete_player(player) do
      send_resp(conn, :no_content, "")
    end
  end
end
