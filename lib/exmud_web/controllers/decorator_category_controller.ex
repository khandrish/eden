defmodule ExmudWeb.DecoratorCategoryController do
  use ExmudWeb, :controller

  alias Exmud.Decorator
  alias Exmud.Decorator.DecoratorCategory

  def new(conn, _params) do
    changeset = Decorator.change_decorator_category(%DecoratorCategory{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"decorator_category" => decorator_category_params}) do
    case Decorator.create_decorator_category(decorator_category_params) do
      {:ok, decorator_category} ->
        conn
        |> put_flash(:info, "Decorator category created successfully.")
        |> redirect(to: Routes.decorator_category_path(conn, :show, decorator_category))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    decorator_category = Decorator.get_decorator_category!(id)
    render(conn, "show.html", decorator_category: decorator_category)
  end

  def edit(conn, %{"id" => id}) do
    decorator_category = Decorator.get_decorator_category!(id)
    changeset = Decorator.change_decorator_category(decorator_category)
    render(conn, "edit.html", decorator_category: decorator_category, changeset: changeset)
  end

  def update(conn, %{"id" => id, "decorator_category" => decorator_category_params}) do
    decorator_category = Decorator.get_decorator_category!(id)

    case Decorator.update_decorator_category(decorator_category, decorator_category_params) do
      {:ok, decorator_category} ->
        conn
        |> put_flash(:info, "Decorator category updated successfully.")
        |> redirect(to: Routes.decorator_category_path(conn, :show, decorator_category))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", decorator_category: decorator_category, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    decorator_category = Decorator.get_decorator_category!(id)
    {:ok, _decorator_category} = Decorator.delete_decorator_category(decorator_category)

    conn
    |> put_flash(:info, "Decorator category deleted successfully.")
    |> redirect(to: Routes.decorator_category_path(conn, :index))
  end
end
