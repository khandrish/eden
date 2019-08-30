defmodule ExmudWeb.EngineCallbackControllerTest do
  use ExmudWeb.ConnCase

  alias Exmud.Engine

  @create_attrs %{config: "some config"}
  @update_attrs %{config: "some updated config"}
  @invalid_attrs %{config: nil}

  def fixture(:mud_callback) do
    {:ok, mud_callback} = Engine.create_mud_callback(@create_attrs)
    mud_callback
  end

  describe "index" do
    test "lists all mud_callbacks", %{conn: conn} do
      conn = get(conn, Routes.mud_callback_path(conn, :index))
      assert html_response(conn, 200) =~ "Listing Engine callbacks"
    end
  end

  describe "new mud_callback" do
    test "renders form", %{conn: conn} do
      conn = get(conn, Routes.mud_callback_path(conn, :new))
      assert html_response(conn, 200) =~ "New Engine callback"
    end
  end

  describe "create mud_callback" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, Routes.mud_callback_path(conn, :create), mud_callback: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.mud_callback_path(conn, :show, id)

      conn = get(conn, Routes.mud_callback_path(conn, :show, id))
      assert html_response(conn, 200) =~ "Show Engine callback"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.mud_callback_path(conn, :create), mud_callback: @invalid_attrs)

      assert html_response(conn, 200) =~ "New Engine callback"
    end
  end

  describe "edit mud_callback" do
    setup [:create_mud_callback]

    test "renders form for editing chosen mud_callback", %{
      conn: conn,
      mud_callback: mud_callback
    } do
      conn = get(conn, Routes.mud_callback_path(conn, :edit, mud_callback))
      assert html_response(conn, 200) =~ "Edit Engine callback"
    end
  end

  describe "update mud_callback" do
    setup [:create_mud_callback]

    test "redirects when data is valid", %{conn: conn, mud_callback: mud_callback} do
      conn =
        put(conn, Routes.mud_callback_path(conn, :update, mud_callback),
          mud_callback: @update_attrs
        )

      assert redirected_to(conn) ==
               Routes.mud_callback_path(conn, :show, mud_callback)

      conn = get(conn, Routes.mud_callback_path(conn, :show, mud_callback))
      assert html_response(conn, 200)
    end

    test "renders errors when data is invalid", %{
      conn: conn,
      mud_callback: mud_callback
    } do
      conn =
        put(conn, Routes.mud_callback_path(conn, :update, mud_callback),
          mud_callback: @invalid_attrs
        )

      assert html_response(conn, 200) =~ "Edit Engine callback"
    end
  end

  describe "delete mud_callback" do
    setup [:create_mud_callback]

    test "deletes chosen mud_callback", %{
      conn: conn,
      mud_callback: mud_callback
    } do
      conn = delete(conn, Routes.mud_callback_path(conn, :delete, mud_callback))
      assert redirected_to(conn) == Routes.mud_callback_path(conn, :index)

      assert_error_sent 404, fn ->
        get(conn, Routes.mud_callback_path(conn, :show, mud_callback))
      end
    end
  end

  defp create_mud_callback(_) do
    mud_callback = fixture(:mud_callback)
    {:ok, mud_callback: mud_callback}
  end
end
