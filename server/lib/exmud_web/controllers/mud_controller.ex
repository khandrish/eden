defmodule ExmudWeb.MudController do
  use ExmudWeb, :controller

  alias Exmud.Engine
  alias Exmud.Engine.Mud

  import Ecto.Query

  action_fallback ExmudWeb.FallbackController

  plug JSONAPI.QueryParser,
    filter: ~w(name inserted_at updated_at),
    sort: ~w(name inserted_at updated_at),
    view: ExmudWeb.MudView

  plug ExmudWeb.Plug.EnforceAuthentication
       when action in [:check_name_and_get_slug, :create, :update]

  plug Hammer.Plug,
       [
         rate_limit: {"mud:check_name_and_get_slug", 30_000, 90},
         by: {:session, :player, &ExmudWeb.Util.get_player_id_from_player/1}
       ]
       when action == :check_name_and_get_slug

  def check_name_and_get_slug(conn, params) do
    slug = Exmud.DataType.NameSlug.build_slug(params["name"])

    count_query =
      from(
        mud in Mud,
        where: mud.name == ^params["name"] or mud.slug == ^slug,
        select: count()
      )

    number_of_muds = Exmud.Repo.one!(count_query)

    if number_of_muds === 0 do
      conn
      |> render("check_name_and_get_slug.json", slug: slug)
    else
      conn
      |> put_status(409)
      |> put_view(ExmudWeb.ErrorView)
      |> render("409.json")
    end
  end

  plug Hammer.Plug,
       [
         rate_limit: {"mud:create", 60_000, 5},
         by: {:session, :player, &ExmudWeb.Util.get_player_id_from_player/1}
       ]
       when action == :create

  def create(conn, params) do
    case Engine.create_mud(params) do
      {:ok, mud = %Mud{}} ->
        conn
        |> put_status(:created)
        |> render("show.json", mud: mud)

      {:error, changeset} ->
        conn
        |> put_status(422)
        |> put_view(ExmudWeb.ErrorView)
        |> render("errors.json", changeset: changeset)
    end
  end

  plug Hammer.Plug,
       [
         rate_limit: {"mud:update", 60_000, 30},
         by: {:session, :player, &ExmudWeb.Util.get_player_id_from_player/1}
       ]
       when action == :update

  def update(conn, params) do
    with {:ok, mud} <- Engine.get_mud(params["id"]),
         {:ok, updated_mud} <- Engine.update_mud(mud, params["attributes"]) do
      conn
      |> put_status(:created)
      |> render("show.json", mud: updated_mud)
    else
      {:error, :not_found} ->
        conn
        |> put_status(404)
        |> send_resp()

      {:error, changeset} ->
        conn
        |> put_status(422)
        |> put_view(ExmudWeb.ErrorView)
        |> render("errors.json", changeset: changeset)

      false ->
        conn
        |> put_status(403)
        |> send_resp()
    end
  end
end
