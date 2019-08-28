defmodule ExmudWeb.PrototypeController do
  use ExmudWeb, :controller

  alias Exmud.Prototype

  def index(conn, _params) do
    prototypes = Prototype.list_prototypes()
    render(conn, "index.html", prototypes: prototypes)
  end

  def new(conn, _params) do
    changeset = Prototype.change_prototype(%Prototype.Prototype{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"prototype" => prototype_params}) do
    case Prototype.create_prototype(prototype_params) do
      {:ok, prototype} ->
        conn
        |> put_flash(:info, "Prototype created successfully.")
        |> redirect(to: Routes.prototype_path(conn, :show, prototype))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    prototype = Prototype.get_prototype!(id)
    render(conn, "show.html", prototype: prototype)
  end

  def edit(conn, %{"id" => id}) do
    prototype = Prototype.get_prototype!(id)
    changeset = Prototype.change_prototype(prototype)
    render(conn, "edit.html", prototype: prototype, changeset: changeset)
  end

  def update(conn, %{"id" => id, "prototype" => prototype_params}) do
    prototype = Prototype.get_prototype!(id)

    case Prototype.update_prototype(prototype, prototype_params) do
      {:ok, prototype} ->
        conn
        |> put_flash(:info, "Prototype updated successfully.")
        |> redirect(to: Routes.prototype_path(conn, :show, prototype))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", prototype: prototype, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    prototype = Prototype.get_prototype!(id)
    {:ok, _prototype} = Prototype.delete_prototype(prototype)

    conn
    |> put_flash(:info, "Prototype deleted successfully.")
    |> redirect(to: Routes.prototype_path(conn, :index))
  end
end
