defmodule ExmudWeb.CategoryController do
  use ExmudWeb, :controller

  alias Exmud.Builder
  alias Exmud.Builder.Category

  plug :put_layout, "left_side_nav.html"

  def index(conn, %{"mud_slug" => mud_slug}) do
    categories =
      Builder.list_categories()
      |> Enum.map(fn category ->
        id =
          if Ecto.assoc_loaded?(category.category) do
            category.category.id
          else
            "#"
          end
          
        %{id: category.id, parent: id, text: category.name}
      end)

    render(conn, "index.html", categories: categories, layout: {ExmudWeb.LayoutView, "jstree.html"}, side_nav_links: side_nav_links(conn, mud_slug))
  end

  def create(conn, %{"category" => category_params, "mud_slug" => mud_slug}) do
    case Builder.create_category(category_params) do
      {:ok, category} ->
        conn
        |> put_flash(:info, "Category created successfully.")
        |> redirect(to: Routes.mud_category_path(conn, :index, mud_slug))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset, side_nav_links: side_nav_links(conn, mud_slug))
    end
  end

  def update(conn, %{"slug" => slug, "category" => category_params, "mud_slug" => mud_slug}) do
    category = Builder.get_category_by_slug!(slug)

    case Builder.update_category(category, category_params) do
      {:ok, category} ->
        conn
        |> put_flash(:info, "Category updated successfully.")
        |> redirect(to: Routes.mud_category_path(conn, :show, mud_slug, category, side_nav_links: side_nav_links(conn, mud_slug)))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", category: category, changeset: changeset, side_nav_links: side_nav_links(conn, mud_slug))
    end
  end

  def delete(conn, %{"slug" => slug, "mud_slug" => mud_slug}) do
    category = Builder.get_category_by_slug!(slug)
    {:ok, _category} = Builder.delete_category(category)

    conn
    |> put_flash(:info, "Category deleted successfully.")
    |> redirect(to: Routes.mud_category_path(conn, :index, mud_slug, side_nav_links: side_nav_links(conn, mud_slug)))
  end

  defp side_nav_links(conn, mud_slug) do
    [
      %{
        disabled?: false,
        path: Routes.mud_prototype_path(conn, :index, mud_slug),
        text: "Prototypes"
      },
      %{
        disabled?: false,
        path: Routes.mud_template_path(conn, :index, mud_slug),
        text: "Templates"
      },
      %{
        disabled?: true,
        path: Routes.mud_category_path(conn, :index, mud_slug),
        text: "Categories"
      }
    ]
  end
end
