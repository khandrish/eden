defmodule ExmudWeb.SimulationControllerTest do
  use ExmudWeb.ConnCase

  alias Exmud.Engine

  @create_attrs %{name: "some name", status: "some status"}
  @update_attrs %{name: "some updated name", status: "some updated status"}
  @invalid_attrs %{name: nil, status: nil}

  def fixture(:simulation) do
    {:ok, simulation} = Engine.create_simulation(@create_attrs)
    simulation
  end

  describe "index" do
    test "lists all simulations", %{conn: conn} do
      conn = get(conn, Routes.simulation_path(conn, :index))
      assert html_response(conn, 200) =~ "Listing Simulations"
    end
  end

  describe "new simulation" do
    test "renders form", %{conn: conn} do
      conn = get(conn, Routes.simulation_path(conn, :new))
      assert html_response(conn, 200) =~ "New Simulation"
    end
  end

  describe "create simulation" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, Routes.simulation_path(conn, :create), simulation: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.simulation_path(conn, :show, id)

      conn = get(conn, Routes.simulation_path(conn, :show, id))
      assert html_response(conn, 200) =~ "Show Simulation"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.simulation_path(conn, :create), simulation: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Simulation"
    end
  end

  describe "edit simulation" do
    setup [:create_simulation]

    test "renders form for editing chosen simulation", %{conn: conn, simulation: simulation} do
      conn = get(conn, Routes.simulation_path(conn, :edit, simulation))
      assert html_response(conn, 200) =~ "Edit Simulation"
    end
  end

  describe "update simulation" do
    setup [:create_simulation]

    test "redirects when data is valid", %{conn: conn, simulation: simulation} do
      conn = put(conn, Routes.simulation_path(conn, :update, simulation), simulation: @update_attrs)
      assert redirected_to(conn) == Routes.simulation_path(conn, :show, simulation)

      conn = get(conn, Routes.simulation_path(conn, :show, simulation))
      assert html_response(conn, 200) =~ "some updated name"
    end

    test "renders errors when data is invalid", %{conn: conn, simulation: simulation} do
      conn = put(conn, Routes.simulation_path(conn, :update, simulation), simulation: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Simulation"
    end
  end

  describe "delete simulation" do
    setup [:create_simulation]

    test "deletes chosen simulation", %{conn: conn, simulation: simulation} do
      conn = delete(conn, Routes.simulation_path(conn, :delete, simulation))
      assert redirected_to(conn) == Routes.simulation_path(conn, :index)
      assert_error_sent 404, fn ->
        get(conn, Routes.simulation_path(conn, :show, simulation))
      end
    end
  end

  defp create_simulation(_) do
    simulation = fixture(:simulation)
    {:ok, simulation: simulation}
  end
end
