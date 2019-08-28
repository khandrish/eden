defmodule ExmudWeb.DecoratorControllerTest do
  use ExmudWeb.ConnCase

  alias Exmud.Engine

  @create_attrs %{category: "some category", name: "some name", type: "some type"}
  @update_attrs %{category: "some updated category", name: "some updated name", type: "some updated type"}
  @invalid_attrs %{category: nil, name: nil, type: nil}

  def fixture(:decorator) do
    {:ok, decorator} = Engine.create_decorator(@create_attrs)
    decorator
  end

  describe "index" do
    test "lists all decorators", %{conn: conn} do
      conn = get(conn, Routes.decorator_path(conn, :index))
      assert html_response(conn, 200) =~ "Listing Decorators"
    end
  end

  describe "new decorator" do
    test "renders form", %{conn: conn} do
      conn = get(conn, Routes.decorator_path(conn, :new))
      assert html_response(conn, 200) =~ "New Decorator"
    end
  end

  describe "create decorator" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, Routes.decorator_path(conn, :create), decorator: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.decorator_path(conn, :show, id)

      conn = get(conn, Routes.decorator_path(conn, :show, id))
      assert html_response(conn, 200) =~ "Show Decorator"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.decorator_path(conn, :create), decorator: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Decorator"
    end
  end

  describe "edit decorator" do
    setup [:create_decorator]

    test "renders form for editing chosen decorator", %{conn: conn, decorator: decorator} do
      conn = get(conn, Routes.decorator_path(conn, :edit, decorator))
      assert html_response(conn, 200) =~ "Edit Decorator"
    end
  end

  describe "update decorator" do
    setup [:create_decorator]

    test "redirects when data is valid", %{conn: conn, decorator: decorator} do
      conn = put(conn, Routes.decorator_path(conn, :update, decorator), decorator: @update_attrs)
      assert redirected_to(conn) == Routes.decorator_path(conn, :show, decorator)

      conn = get(conn, Routes.decorator_path(conn, :show, decorator))
      assert html_response(conn, 200) =~ "some updated category"
    end

    test "renders errors when data is invalid", %{conn: conn, decorator: decorator} do
      conn = put(conn, Routes.decorator_path(conn, :update, decorator), decorator: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Decorator"
    end
  end

  describe "delete decorator" do
    setup [:create_decorator]

    test "deletes chosen decorator", %{conn: conn, decorator: decorator} do
      conn = delete(conn, Routes.decorator_path(conn, :delete, decorator))
      assert redirected_to(conn) == Routes.decorator_path(conn, :index)
      assert_error_sent 404, fn ->
        get(conn, Routes.decorator_path(conn, :show, decorator))
      end
    end
  end

  defp create_decorator(_) do
    decorator = fixture(:decorator)
    {:ok, decorator: decorator}
  end
end
