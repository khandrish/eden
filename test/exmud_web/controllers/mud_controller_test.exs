defmodule ExmudWeb.EngineControllerTest do
  use ExmudWeb.ConnCase

  alias Exmud.Engine

  @create_attrs %{name: "some name", status: "some status"}
  @update_attrs %{name: "some updated name", status: "some updated status"}
  @invalid_attrs %{name: nil, status: nil}

  def fixture(:mud) do
    {:ok, mud} = Engine.create_mud(@create_attrs)
    mud
  end

  describe "index" do
    test "lists all muds", %{conn: conn} do
      conn = get(conn, Routes.mud_path(conn, :index))
      assert html_response(conn, 200) =~ "Listing Engines"
    end
  end

  describe "new mud" do
    test "renders form", %{conn: conn} do
      conn = get(conn, Routes.mud_path(conn, :new))
      assert html_response(conn, 200) =~ "New Engine"
    end
  end

  describe "create mud" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, Routes.mud_path(conn, :create), mud: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.mud_path(conn, :show, id)

      conn = get(conn, Routes.mud_path(conn, :show, id))
      assert html_response(conn, 200) =~ "Show Engine"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.mud_path(conn, :create), mud: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Engine"
    end
  end

  describe "edit mud" do
    setup [:create_mud]

    test "renders form for editing chosen mud", %{conn: conn, mud: mud} do
      conn = get(conn, Routes.mud_path(conn, :edit, mud))
      assert html_response(conn, 200) =~ "Edit Engine"
    end
  end

  describe "update mud" do
    setup [:create_mud]

    test "redirects when data is valid", %{conn: conn, mud: mud} do
      conn = put(conn, Routes.mud_path(conn, :update, mud), mud: @update_attrs)
      assert redirected_to(conn) == Routes.mud_path(conn, :show, mud)

      conn = get(conn, Routes.mud_path(conn, :show, mud))
      assert html_response(conn, 200) =~ "some updated name"
    end

    test "renders errors when data is invalid", %{conn: conn, mud: mud} do
      conn = put(conn, Routes.mud_path(conn, :update, mud), mud: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Engine"
    end
  end

  describe "delete mud" do
    setup [:create_mud]

    test "deletes chosen mud", %{conn: conn, mud: mud} do
      conn = delete(conn, Routes.mud_path(conn, :delete, mud))
      assert redirected_to(conn) == Routes.mud_path(conn, :index)

      assert_error_sent 404, fn ->
        get(conn, Routes.mud_path(conn, :show, mud))
      end
    end
  end

  defp create_mud(_) do
    mud = fixture(:mud)
    {:ok, mud: mud}
  end
end
