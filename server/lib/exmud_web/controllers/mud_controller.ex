defmodule ExmudWeb.MudController do
  use ExmudWeb, :controller

  alias Exmud.Engine
  alias Exmud.Engine.Mud

  plug :put_layout, "left_side_nav.html"

  def index(conn, _params) do
    muds = Engine.list_muds()
    render(conn, "index.html", layout: {ExmudWeb.LayoutView, "app.html"}, muds: muds)
  end

  def new(conn, _params) do
    changeset = Engine.change_mud(%Mud{})
    render(conn, "new.html", changeset: changeset, layout: {ExmudWeb.LayoutView, "form.html"})
  end

  def create(conn, %{"mud" => mud_params}) do
    case Engine.create_mud(mud_params) do
      {:ok, mud} ->
        conn
        |> put_flash(:info, "Engine created successfully.")
        |> redirect(to: Routes.mud_path(conn, :show, mud.slug))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  @spec show(Plug.Conn.t(), map) :: Plug.Conn.t()
  def show(conn, %{"slug" => slug}) do
    mud = Engine.get_mud_by_slug!(slug)

    render(conn, "show.html", mud: mud, layout: {ExmudWeb.LayoutView, "app.html"})
  end

  @spec build(Plug.Conn.t(), map) :: Plug.Conn.t()
  def build(conn, %{"slug" => slug}) do
    mud = Engine.get_mud_by_slug!(slug)
    changeset = Engine.change_mud(mud)

    render(conn, "edit.html",
      changeset: changeset,
      has_name_error?: false,
      layout: {ExmudWeb.LayoutView, "form.html"}
    )
  end

  @spec edit(Plug.Conn.t(), map) :: Plug.Conn.t()
  def edit(conn, %{"slug" => slug}) do
    mud = Engine.get_mud_by_slug!(slug)
    changeset = Engine.change_mud(mud)

    render(conn, "edit.html",
      changeset: changeset,
      has_name_error?: false,
      layout: {ExmudWeb.LayoutView, "form.html"}
    )
  end

  @spec update(Plug.Conn.t(), map) :: Plug.Conn.t()
  def update(conn, %{"slug" => slug, "mud" => mud_params}) do
    mud = Engine.get_mud_by_slug!(slug)

    case Engine.update_mud(mud, mud_params) do
      {:ok, mud} ->
        conn
        |> put_flash(:info, "Engine updated successfully.")
        |> redirect(to: Routes.mud_path(conn, :show, mud))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", mud: mud, changeset: changeset)
    end
  end

  def delete(conn, %{"slug" => slug}) do
    mud = Engine.get_mud_by_slug!(slug)
    {:ok, _mud} = Engine.delete_mud(mud)

    conn
    |> put_flash(:info, "Engine deleted successfully.")
    |> redirect(to: Routes.mud_path(conn, :index))
  end
end
