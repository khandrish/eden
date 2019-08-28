defmodule ExmudWeb.DecoratorTypeController do
  use ExmudWeb, :controller

  alias Exmud.Decorator
  alias Exmud.Decorator.DecoratorType

  def new(conn, _params) do
    changeset = Decorator.change_decorator_type(%DecoratorType{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"decorator_type" => decorator_type_params}) do
    case Decorator.create_decorator_type(decorator_type_params) do
      {:ok, decorator_type} ->
        conn
        |> put_flash(:info, "Decorator type created successfully.")
        |> redirect(to: Routes.decorator_type_path(conn, :show, decorator_type))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    decorator_type = Decorator.get_decorator_type!(id)
    render(conn, "show.html", decorator_type: decorator_type)
  end

  def edit(conn, %{"id" => id}) do
    decorator_type = Decorator.get_decorator_type!(id)
    changeset = Decorator.change_decorator_type(decorator_type)
    render(conn, "edit.html", decorator_type: decorator_type, changeset: changeset)
  end

  def update(conn, %{"id" => id, "decorator_type" => decorator_type_params}) do
    decorator_type = Decorator.get_decorator_type!(id)

    case Decorator.update_decorator_type(decorator_type, decorator_type_params) do
      {:ok, decorator_type} ->
        conn
        |> put_flash(:info, "Decorator type updated successfully.")
        |> redirect(to: Routes.decorator_type_path(conn, :show, decorator_type))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", decorator_type: decorator_type, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    decorator_type = Decorator.get_decorator_type!(id)
    {:ok, _decorator_type} = Decorator.delete_decorator_type(decorator_type)

    conn
    |> put_flash(:info, "Decorator type deleted successfully.")
    |> redirect(to: Routes.decorator_type_path(conn, :index))
  end
end
