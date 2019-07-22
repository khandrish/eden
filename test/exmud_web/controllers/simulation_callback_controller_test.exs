defmodule ExmudWeb.SimulationCallbackControllerTest do
  use ExmudWeb.ConnCase

  alias Exmud.Engine

  @create_attrs %{default_config: "some default_config"}
  @update_attrs %{default_config: "some updated default_config"}
  @invalid_attrs %{default_config: nil}

  def fixture(:simulation_callback) do
    {:ok, simulation_callback} = Engine.create_simulation_callback(@create_attrs)
    simulation_callback
  end

  describe "index" do
    test "lists all simulation_callbacks", %{conn: conn} do
      conn = get(conn, Routes.simulation_callback_path(conn, :index))
      assert html_response(conn, 200) =~ "Listing Simulation callbacks"
    end
  end

  describe "new simulation_callback" do
    test "renders form", %{conn: conn} do
      conn = get(conn, Routes.simulation_callback_path(conn, :new))
      assert html_response(conn, 200) =~ "New Simulation callback"
    end
  end

  describe "create simulation_callback" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn =
        post(conn, Routes.simulation_callback_path(conn, :create),
          simulation_callback: @create_attrs
        )

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.simulation_callback_path(conn, :show, id)

      conn = get(conn, Routes.simulation_callback_path(conn, :show, id))
      assert html_response(conn, 200) =~ "Show Simulation callback"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn =
        post(conn, Routes.simulation_callback_path(conn, :create),
          simulation_callback: @invalid_attrs
        )

      assert html_response(conn, 200) =~ "New Simulation callback"
    end
  end

  describe "edit simulation_callback" do
    setup [:create_simulation_callback]

    test "renders form for editing chosen simulation_callback", %{
      conn: conn,
      simulation_callback: simulation_callback
    } do
      conn = get(conn, Routes.simulation_callback_path(conn, :edit, simulation_callback))
      assert html_response(conn, 200) =~ "Edit Simulation callback"
    end
  end

  describe "update simulation_callback" do
    setup [:create_simulation_callback]

    test "redirects when data is valid", %{conn: conn, simulation_callback: simulation_callback} do
      conn =
        put(conn, Routes.simulation_callback_path(conn, :update, simulation_callback),
          simulation_callback: @update_attrs
        )

      assert redirected_to(conn) ==
               Routes.simulation_callback_path(conn, :show, simulation_callback)

      conn = get(conn, Routes.simulation_callback_path(conn, :show, simulation_callback))
      assert html_response(conn, 200)
    end

    test "renders errors when data is invalid", %{
      conn: conn,
      simulation_callback: simulation_callback
    } do
      conn =
        put(conn, Routes.simulation_callback_path(conn, :update, simulation_callback),
          simulation_callback: @invalid_attrs
        )

      assert html_response(conn, 200) =~ "Edit Simulation callback"
    end
  end

  describe "delete simulation_callback" do
    setup [:create_simulation_callback]

    test "deletes chosen simulation_callback", %{
      conn: conn,
      simulation_callback: simulation_callback
    } do
      conn = delete(conn, Routes.simulation_callback_path(conn, :delete, simulation_callback))
      assert redirected_to(conn) == Routes.simulation_callback_path(conn, :index)

      assert_error_sent 404, fn ->
        get(conn, Routes.simulation_callback_path(conn, :show, simulation_callback))
      end
    end
  end

  defp create_simulation_callback(_) do
    simulation_callback = fixture(:simulation_callback)
    {:ok, simulation_callback: simulation_callback}
  end
end
