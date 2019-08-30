defmodule ExmudWeb.IdentityControllerTest do
  use ExmudWeb.ConnCase

  alias Exmud.Account

  @create_attrs %{data: "some data", key: "some key", type: "some type"}
  @update_attrs %{data: "some updated data", key: "some updated key", type: "some updated type"}
  @invalid_attrs %{data: nil, key: nil, type: nil}

  def fixture(:identity) do
    {:ok, identity} = Account.create_identity(@create_attrs)
    identity
  end

  describe "index" do
    test "lists all identities", %{conn: conn} do
      conn = get(conn, Routes.identity_path(conn, :index))
      assert html_response(conn, 200) =~ "Listing Identities"
    end
  end

  describe "new identity" do
    test "renders form", %{conn: conn} do
      conn = get(conn, Routes.identity_path(conn, :new))
      assert html_response(conn, 200) =~ "New Identity"
    end
  end

  describe "create identity" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, Routes.identity_path(conn, :create), identity: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.identity_path(conn, :show, id)

      conn = get(conn, Routes.identity_path(conn, :show, id))
      assert html_response(conn, 200) =~ "Show Identity"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.identity_path(conn, :create), identity: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Identity"
    end
  end

  describe "edit identity" do
    setup [:create_identity]

    test "renders form for editing chosen identity", %{conn: conn, identity: identity} do
      conn = get(conn, Routes.identity_path(conn, :edit, identity))
      assert html_response(conn, 200) =~ "Edit Identity"
    end
  end

  describe "update identity" do
    setup [:create_identity]

    test "redirects when data is valid", %{conn: conn, identity: identity} do
      conn = put(conn, Routes.identity_path(conn, :update, identity), identity: @update_attrs)
      assert redirected_to(conn) == Routes.identity_path(conn, :show, identity)

      conn = get(conn, Routes.identity_path(conn, :show, identity))
      assert html_response(conn, 200) =~ "some updated key"
    end

    test "renders errors when data is invalid", %{conn: conn, identity: identity} do
      conn = put(conn, Routes.identity_path(conn, :update, identity), identity: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Identity"
    end
  end

  describe "delete identity" do
    setup [:create_identity]

    test "deletes chosen identity", %{conn: conn, identity: identity} do
      conn = delete(conn, Routes.identity_path(conn, :delete, identity))
      assert redirected_to(conn) == Routes.identity_path(conn, :index)
      assert_error_sent 404, fn ->
        get(conn, Routes.identity_path(conn, :show, identity))
      end
    end
  end

  defp create_identity(_) do
    identity = fixture(:identity)
    {:ok, identity: identity}
  end
end
