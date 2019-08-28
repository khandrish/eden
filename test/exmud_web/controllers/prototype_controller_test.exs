defmodule ExmudWeb.PrototypeControllerTest do
  use ExmudWeb.ConnCase

  alias Exmud.Prototype

  @create_attrs %{name: "some name"}
  @update_attrs %{name: "some updated name"}
  @invalid_attrs %{name: nil}

  def fixture(:prototype) do
    {:ok, prototype} = Prototype.create_prototype(@create_attrs)
    prototype
  end

  describe "index" do
    test "lists all prototypes", %{conn: conn} do
      conn = get(conn, Routes.prototype_path(conn, :index))
      assert html_response(conn, 200) =~ "Listing Prototypes"
    end
  end

  describe "new prototype" do
    test "renders form", %{conn: conn} do
      conn = get(conn, Routes.prototype_path(conn, :new))
      assert html_response(conn, 200) =~ "New Prototype"
    end
  end

  describe "create prototype" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, Routes.prototype_path(conn, :create), prototype: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.prototype_path(conn, :show, id)

      conn = get(conn, Routes.prototype_path(conn, :show, id))
      assert html_response(conn, 200) =~ "Show Prototype"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.prototype_path(conn, :create), prototype: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Prototype"
    end
  end

  describe "edit prototype" do
    setup [:create_prototype]

    test "renders form for editing chosen prototype", %{conn: conn, prototype: prototype} do
      conn = get(conn, Routes.prototype_path(conn, :edit, prototype))
      assert html_response(conn, 200) =~ "Edit Prototype"
    end
  end

  describe "update prototype" do
    setup [:create_prototype]

    test "redirects when data is valid", %{conn: conn, prototype: prototype} do
      conn = put(conn, Routes.prototype_path(conn, :update, prototype), prototype: @update_attrs)

      assert redirected_to(conn) == Routes.prototype_path(conn, :show, prototype)

      conn = get(conn, Routes.prototype_path(conn, :show, prototype))
      assert html_response(conn, 200) =~ "some updated name"
    end

    test "renders errors when data is invalid", %{conn: conn, prototype: prototype} do
      conn = put(conn, Routes.prototype_path(conn, :update, prototype), prototype: @invalid_attrs)

      assert html_response(conn, 200) =~ "Edit Prototype"
    end
  end

  describe "delete prototype" do
    setup [:create_prototype]

    test "deletes chosen prototype", %{conn: conn, prototype: prototype} do
      conn = delete(conn, Routes.prototype_path(conn, :delete, prototype))
      assert redirected_to(conn) == Routes.prototype_path(conn, :index)

      assert_error_sent 404, fn ->
        get(conn, Routes.prototype_path(conn, :show, prototype))
      end
    end
  end

  defp create_prototype(_) do
    prototype = fixture(:prototype)
    {:ok, prototype: prototype}
  end
end
