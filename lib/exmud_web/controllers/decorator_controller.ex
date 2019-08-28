defmodule ExmudWeb.DecoratorController do
  use ExmudWeb, :controller

  alias Exmud.Decorator

  def index(conn, _params) do
    decorators = Decorator.list_decorators()
    render(conn, "index.html", decorators: decorators)
  end

  def new(conn, _params) do
    changeset = Decorator.change_decorator(%Decorator.Decorator{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"decorator" => decorator_params}) do
    case Decorator.create_decorator(decorator_params) do
      {:ok, decorator} ->
        conn
        |> put_flash(:info, "Decorator created successfully.")
        |> redirect(to: Routes.decorator_path(conn, :show, decorator))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    decorator = Decorator.get_decorator!(id)
    render(conn, "show.html", decorator: decorator)
  end

  def edit(conn, %{"id" => id}) do
    decorator = Decorator.get_decorator!(id)
    changeset = Decorator.change_decorator(decorator)
    render(conn, "edit.html", decorator: decorator, changeset: changeset)
  end

  def update(conn, %{"id" => id, "decorator" => decorator_params}) do
    decorator = Decorator.get_decorator!(id)

    case Decorator.update_decorator(decorator, decorator_params) do
      {:ok, decorator} ->
        conn
        |> put_flash(:info, "Decorator updated successfully.")
        |> redirect(to: Routes.decorator_path(conn, :show, decorator))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", decorator: decorator, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    decorator = Decorator.get_decorator!(id)
    {:ok, _decorator} = Decorator.delete_decorator(decorator)

    conn
    |> put_flash(:info, "Decorator deleted successfully.")
    |> redirect(to: Routes.decorator_path(conn, :index))
  end
end
