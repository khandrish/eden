defmodule ExmudWeb.CallbacksControllerTest do
  use ExmudWeb.ConnCase

  alias Exmud.Engine

  @create_attrs %{default_args: "some default_args", module: "some module", type: "some type"}
  @update_attrs %{
    default_args: "some updated default_args",
    module: "some updated module",
    type: "some updated type"
  }
  @invalid_attrs %{default_args: nil, module: nil, type: nil}

  def fixture(:callbacks) do
    {:ok, callbacks} = Engine.create_callbacks(@create_attrs)
    callbacks
  end

  describe "index" do
    test "lists all callbacks", %{conn: conn} do
      conn = get(conn, Routes.callback_path(conn, :index))
      assert html_response(conn, 200) =~ "Listing Callbacks"
    end
  end

  describe "new callbacks" do
    test "renders form", %{conn: conn} do
      conn = get(conn, Routes.callback_path(conn, :new))
      assert html_response(conn, 200) =~ "New Callbacks"
    end
  end

  describe "create callbacks" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, Routes.callback_path(conn, :create), callbacks: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.callback_path(conn, :show, id)

      conn = get(conn, Routes.callback_path(conn, :show, id))
      assert html_response(conn, 200) =~ "Show Callbacks"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.callback_path(conn, :create), callbacks: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Callbacks"
    end
  end

  describe "edit callbacks" do
    setup [:create_callbacks]

    test "renders form for editing chosen callbacks", %{conn: conn, callbacks: callbacks} do
      conn = get(conn, Routes.callback_path(conn, :edit, callbacks))
      assert html_response(conn, 200) =~ "Edit Callbacks"
    end
  end

  describe "update callbacks" do
    setup [:create_callbacks]

    test "redirects when data is valid", %{conn: conn, callbacks: callbacks} do
      conn = put(conn, Routes.callback_path(conn, :update, callbacks), callbacks: @update_attrs)
      assert redirected_to(conn) == Routes.callback_path(conn, :show, callbacks)

      conn = get(conn, Routes.callback_path(conn, :show, callbacks))
      assert html_response(conn, 200) =~ "some updated module"
    end

    test "renders errors when data is invalid", %{conn: conn, callbacks: callbacks} do
      conn = put(conn, Routes.callback_path(conn, :update, callbacks), callbacks: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Callbacks"
    end
  end

  describe "delete callbacks" do
    setup [:create_callbacks]

    test "deletes chosen callbacks", %{conn: conn, callbacks: callbacks} do
      conn = delete(conn, Routes.callback_path(conn, :delete, callbacks))
      assert redirected_to(conn) == Routes.callback_path(conn, :index)

      assert_error_sent 404, fn ->
        get(conn, Routes.callback_path(conn, :show, callbacks))
      end
    end
  end

  defp create_callbacks(_) do
    callbacks = fixture(:callbacks)
    {:ok, callbacks: callbacks}
  end
end
