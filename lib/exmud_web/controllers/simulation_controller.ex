defmodule ExmudWeb.SimulationController do
  use ExmudWeb, :controller

  alias Exmud.Engine
  alias Exmud.Engine.Simulation

  def index(conn, _params) do
    simulations = Engine.list_simulations()
    render(conn, "index.html", simulations: simulations)
  end

  def new(conn, _params) do
    changeset = Engine.change_simulation(%Simulation{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"simulation" => simulation_params}) do
    case Engine.create_simulation(simulation_params) do
      {:ok, simulation} ->
        conn
        |> put_flash(:info, "Simulation created successfully.")
        |> redirect(to: Routes.simulation_path(conn, :show, simulation))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    simulation = Engine.get_simulation!(id)
    render(conn, "show.html", simulation: simulation)
  end

  def edit(conn, %{"id" => id}) do
    simulation = Engine.get_simulation!(id)
    changeset = Engine.change_simulation(simulation)
    render(conn, "edit.html", simulation: simulation, changeset: changeset)
  end

  def update(conn, %{"id" => id, "simulation" => simulation_params}) do
    simulation = Engine.get_simulation!(id)

    case Engine.update_simulation(simulation, simulation_params) do
      {:ok, simulation} ->
        conn
        |> put_flash(:info, "Simulation updated successfully.")
        |> redirect(to: Routes.simulation_path(conn, :show, simulation))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", simulation: simulation, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    simulation = Engine.get_simulation!(id)
    {:ok, _simulation} = Engine.delete_simulation(simulation)

    conn
    |> put_flash(:info, "Simulation deleted successfully.")
    |> redirect(to: Routes.simulation_path(conn, :index))
  end
end
