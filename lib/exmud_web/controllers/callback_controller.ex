defmodule ExmudWeb.CallbackController do
  use ExmudWeb, :controller

  alias Exmud.Engine
  alias Exmud.Engine.Callback

  def index(conn, _params) do
    callbacks =
      Engine.list_callbacks()
      |> Enum.map(fn callback ->
        %{callback | docs: Exmud.Util.get_module_docs(callback.module)}
      end)

    render(conn, "index.html", callbacks: callbacks)
  end

  def new(conn, _params) do
    changeset = Engine.change_callback(%Callback{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"callback" => callback_params}) do
    case Engine.create_callback(callback_params) do
      {:ok, callback} ->
        conn
        |> put_flash(:info, "Callback created successfully.")
        |> redirect(to: Routes.callback_path(conn, :show, callback))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    callback = Engine.get_callback!(id)
    render(conn, "show.html", callback: callback)
  end

  def edit(conn, %{"id" => id}) do
    callback = Engine.get_callback!(id)
    changeset = Engine.change_callback(callback)
    render(conn, "edit.html", callback: callback, changeset: changeset)
  end

  def update(conn, %{"id" => id, "callback" => callback_params}) do
    callback = Engine.get_callback!(id)

    case Engine.update_callback(callback, callback_params) do
      {:ok, callback} ->
        conn
        |> put_flash(:info, "Callback updated successfully.")
        |> redirect(to: Routes.callback_path(conn, :show, callback))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", callback: callback, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    callback = Engine.get_callback!(id)
    {:ok, _callback} = Engine.delete_callback(callback)

    conn
    |> put_flash(:info, "Callback deleted successfully.")
    |> redirect(to: Routes.callback_path(conn, :index))
  end
end
