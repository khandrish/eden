defmodule ExmudWeb.CategoryController do
  use ExmudWeb, :controller

  alias Exmud.Builder
  alias Exmud.Builder.Category

  def index(conn, _params) do
    categories = Builder.list_categories()
    render(conn, "index.html", categories: categories)
  end

  def new(conn, _params) do
    changeset = Builder.change_category(%Category{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"category" => category_params, "mud_slug" => mud_slug}) do
    case Builder.create_category(category_params) do
      {:ok, category} ->
        conn
        |> put_flash(:info, "Category created successfully.")
        |> redirect(to: Routes.mud_category_path(conn, :show, mud_slug, category))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    category = Builder.get_category!(id)
    render(conn, "show.html", category: category)
  end

  def edit(conn, %{"id" => id}) do
    category = Builder.get_category!(id)
    changeset = Builder.change_category(category)
    render(conn, "edit.html", category: category, changeset: changeset)
  end

  def update(conn, %{"id" => id, "category" => category_params, "mud_slug" => mud_slug}) do
    category = Builder.get_category!(id)

    case Builder.update_category(category, category_params) do
      {:ok, category} ->
        conn
        |> put_flash(:info, "Category updated successfully.")
        |> redirect(to: Routes.mud_category_path(conn, :show, mud_slug, category))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", category: category, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id, "mud_slug" => mud_slug}) do
    category = Builder.get_category!(id)
    {:ok, _category} = Builder.delete_category(category)

    conn
    |> put_flash(:info, "Category deleted successfully.")
    |> redirect(to: Routes.mud_category_path(conn, :index, mud_slug))
  end
end
