defmodule ExmudWeb.CharacterController do
  use ExmudWeb, :controller

  alias Exmud.Engine
  alias Exmud.Engine.Character

  action_fallback ExmudWeb.FallbackController

  plug ExmudWeb.Plug.EnforceAuthentication
       when action in [:create, :delete, :get, :list_player_characters, :update]

  @spec list_player_characters(Plug.Conn.t(), %{playerId: String.t()}) :: Plug.Conn.t()
  def list_player_characters(conn, %{"playerId" => player_id}) do
    if conn.assigns.player.id === player_id do
      {:ok, characters} = Engine.list_player_characters(player_id)
      render(conn, "index.json", characters: characters)
    else
      conn
      |> put_status(401)
      |> put_view(ExmudWeb.ErrorView)
      |> render("401.json")
    end
  end

  def create(conn, %{"character" => character_params}) do
    case Engine.create_character(character_params) do
      {:ok, %Character{} = character} ->
        conn
        |> put_status(:created)
        |> render("show.json", character: character)

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> put_view(ExmudWeb.ErrorView)
        |> render("error.json", changeset: changeset)
    end
  end

  def get(conn, %{"slug" => slug}) do
    case Engine.get_character_by_slug(slug) do
      {:ok, %Character{} = character} ->
        render(conn, "show.json", character: character)

      {:error, :not_found} ->
        conn
        |> put_status(404)
        |> put_view(ExmudWeb.ErrorView)
        |> render("404.json")
    end
  end

  def get(conn, %{"id" => id}) do
    case Engine.get_character_by_id(id) do
      {:ok, %Character{} = character} ->
        render(conn, "show.json", character: character)

      {:error, :not_found} ->
        conn
        |> put_status(404)
        |> put_view(ExmudWeb.ErrorView)
        |> render("404.json")
    end
  end

  def update(conn, %{"id" => id, "character" => character_params}) do
    with {:ok, character} <- Engine.get_character_by_id(id),
         {:ok, updated_character} <- Engine.update_character(character, character_params) do
      render(conn, "show.json", character: updated_character)
    else
      {:error, :not_found} ->
        conn
        |> put_status(404)
        |> put_view(ExmudWeb.ErrorView)
        |> render("404.json")

      {:error, changeset = %Ecto.Changeset{}} ->
        conn
        |> put_status(:unprocessable_entity)
        |> put_view(ExmudWeb.ErrorView)
        |> render("error.json", changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    character = Engine.get_character_by_id!(id)

    with {:ok, %Character{}} <- Engine.delete_character(character) do
      send_resp(conn, :no_content, "")
    end
  end
end
