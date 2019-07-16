defmodule ExmudWeb.CallbackController do
  use ExmudWeb, :controller

  alias Exmud.Engine
  alias Exmud.Engine.Callbacks

  def index(conn, _params) do
    callbacks = Engine.list_callbacks()
    render(conn, "index.html", callbacks: callbacks)
  end

  def new(conn, _params) do
    changeset = Engine.change_callbacks(%Callbacks{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"callbacks" => callbacks_params}) do
    case Engine.create_callbacks(callbacks_params) do
      {:ok, callbacks} ->
        conn
        |> put_flash(:info, "Callbacks created successfully.")
        |> redirect(to: Routes.callback_path(conn, :show, callbacks))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    callbacks = Engine.get_callbacks!(id)
    render(conn, "show.html", callbacks: callbacks)
  end

  def edit(conn, %{"id" => id}) do
    callbacks = Engine.get_callbacks!(id)
    changeset = Engine.change_callbacks(callbacks)
    render(conn, "edit.html", callbacks: callbacks, changeset: changeset)
  end

  def update(conn, %{"id" => id, "callbacks" => callbacks_params}) do
    callbacks = Engine.get_callbacks!(id)

    case Engine.update_callbacks(callbacks, callbacks_params) do
      {:ok, callbacks} ->
        conn
        |> put_flash(:info, "Callbacks updated successfully.")
        |> redirect(to: Routes.callback_path(conn, :show, callbacks))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", callbacks: callbacks, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    callbacks = Engine.get_callbacks!(id)
    {:ok, _callbacks} = Engine.delete_callbacks(callbacks)

    conn
    |> put_flash(:info, "Callbacks deleted successfully.")
    |> redirect(to: Routes.callback_path(conn, :index))
  end
end
