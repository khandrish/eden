defmodule ExmudWeb.PlayerController do
  use ExmudWeb, :controller

  alias Exmud.Account
  alias Exmud.Account.Player

  action_fallback ExmudWeb.FallbackController

  plug ExmudWeb.Plug.EnforceAuthentication when action in [:create, :delete, :get_authenticated_player, :index, :show, :update]

  def index(conn, params) do
    page = Map.get(params, "page", 1)
    page_size = Map.get(params, "pageSize", 10)
    {:ok, players} = Account.list_players(page, page_size)
    render(conn, "index.json", players: players)
  end

  def create(conn, %{"player" => player_params}) do
    case Account.create_player(player_params) do
    {:ok, %Player{} = player} ->
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.player_path(conn, :show, player))
      |> render("show.json", player: player)
    {:error, changeset} ->
      if changeset.valid? do
        conn
        |> put_status(500)
        |> put_view(ExmudWeb.ErrorView)
        |> render("500.json")
      else
        conn
        |> put_status(422)
        |> put_view(ExmudWeb.ErrorView)
        |> render("422.json")
      end
    end
  end

  def show(conn, %{"id" => id}) do
    player = Account.get_player!(id)
    render(conn, "show.json", player: player)
  end

  def update(conn, %{"id" => id, "player" => player_params}) do
    player = Account.get_player!(id)

    case Account.update_player(player, player_params) do
      {:ok, %Player{} = player} ->
        conn
        |> put_status(200)
        |> render("show.json", player: player)
      {:error, changeset} ->
        if changeset.valid? do
          conn
          |> put_status(500)
          |> put_view(ExmudWeb.ErrorView)
          |> render("500.json")
        else
          conn
          |> put_status(422)
          |> put_view(ExmudWeb.ErrorView)
          |> render("422.json")
        end
    end
  end

  def get_authenticated_player(conn, _params) do
    IO.inspect(conn)
    IO.inspect(conn.assigns)
    if conn.assigns.player_authenticated? do
      render(conn, "show.json", player: conn.assigns.player)
    else
      conn
      |> put_status(401)
      |> put_view(ExmudWeb.ErrorView)
      |> render("401.json")
    end
  end

  def delete(conn, %{"id" => id}) do
    player = Account.get_player!(id)

    with {:ok, %Player{}} <- Account.delete_player(player) do
      send_resp(conn, :no_content, "")
    end
  end
end
