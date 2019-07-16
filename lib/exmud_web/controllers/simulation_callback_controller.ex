defmodule ExmudWeb.SimulationCallbackController do
  use ExmudWeb, :controller

  alias Exmud.Engine
  alias Exmud.Engine.SimulationCallback

  def index(conn, _params) do
    simulation_callbacks = Engine.list_simulation_callbacks()
    render(conn, "index.html", simulation_callbacks: simulation_callbacks)
  end

  def new(conn, _params) do
    changeset = Engine.change_simulation_callback(%SimulationCallback{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"simulation_callback" => simulation_callback_params}) do
    case Engine.create_simulation_callback(simulation_callback_params) do
      {:ok, simulation_callback} ->
        conn
        |> put_flash(:info, "Simulation callback created successfully.")
        |> redirect(to: Routes.simulation_callback_path(conn, :show, simulation_callback))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    simulation_callback = Engine.get_simulation_callback!(id)
    render(conn, "show.html", simulation_callback: simulation_callback)
  end

  def edit(conn, %{"id" => id}) do
    simulation_callback = Engine.get_simulation_callback!(id)
    changeset = Engine.change_simulation_callback(simulation_callback)
    render(conn, "edit.html", simulation_callback: simulation_callback, changeset: changeset)
  end

  def update(conn, %{"id" => id, "simulation_callback" => simulation_callback_params}) do
    simulation_callback = Engine.get_simulation_callback!(id)

    case Engine.update_simulation_callback(simulation_callback, simulation_callback_params) do
      {:ok, simulation_callback} ->
        conn
        |> put_flash(:info, "Simulation callback updated successfully.")
        |> redirect(to: Routes.simulation_callback_path(conn, :show, simulation_callback))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", simulation_callback: simulation_callback, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    simulation_callback = Engine.get_simulation_callback!(id)
    {:ok, _simulation_callback} = Engine.delete_simulation_callback(simulation_callback)

    conn
    |> put_flash(:info, "Simulation callback deleted successfully.")
    |> redirect(to: Routes.simulation_callback_path(conn, :index))
  end
end
