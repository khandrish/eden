defmodule ExmudWeb.PrototypeController do
  use ExmudWeb, :controller

  alias Exmud.Builder
  alias Exmud.Builder.Prototype

  def index(conn, _params = %{"mud_slug" => slug}) do
    prototypes = Builder.list_prototypes()

    render(conn, "index.html",
      layout: {ExmudWeb.LayoutView, "table.html"},
      prototypes: prototypes,
      slug: slug
    )
  end

  def new(conn, _params) do
    changeset = Builder.change_prototype(%Prototype{})
    render(conn, "new.html", changeset: changeset, layout: {ExmudWeb.LayoutView, "form.html"})
  end

  def create(conn, %{
        "prototype" => prototype_params,
        "mud_slug" => mud_slug
      }) do
    case Builder.create_prototype(prototype_params) do
      {:ok, prototype} ->
        conn
        |> put_flash(:info, "Prototype created successfully.")
        |> redirect(to: Routes.mud_prototype_path(conn, :show, mud_slug, prototype))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"slug" => slug}) do
    prototype = Builder.get_prototype!(slug)
    render(conn, "show.html", prototype: prototype)
  end

  def edit(conn, %{"slug" => slug}) do
    prototype = Builder.get_prototype!(slug)
    changeset = Builder.change_prototype(prototype)
    render(conn, "edit.html", prototype: prototype, changeset: changeset)
  end

  def update(conn, %{"slug" => slug, "prototype" => prototype_params}) do
    prototype = Builder.get_prototype!(slug)

    case Builder.update_prototype(prototype, prototype_params) do
      {:ok, prototype} ->
        conn
        |> put_flash(:info, "Prototype updated successfully.")
        |> redirect(to: Routes.mud_prototype_path(conn, :show, slug, prototype))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", prototype: prototype, changeset: changeset)
    end
  end

  def delete(conn, %{"slug" => slug}) do
    prototype = Builder.get_prototype!(slug)
    {:ok, _prototype} = Builder.delete_prototype(prototype)

    conn
    |> put_flash(:info, "Prototype deleted successfully.")
    |> redirect(to: "/")
  end
end
