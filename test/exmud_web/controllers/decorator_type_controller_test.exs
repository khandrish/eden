defmodule ExmudWeb.DecoratorTypeControllerTest do
  use ExmudWeb.ConnCase

  alias Exmud.Decorator

  @create_attrs %{name: "some name"}
  @update_attrs %{name: "some updated name"}
  @invalid_attrs %{name: nil}

  def fixture(:decorator_type) do
    {:ok, decorator_type} = Decorator.create_decorator_type(@create_attrs)
    decorator_type
  end

  describe "index" do
    test "lists all decorator_types", %{conn: conn} do
      conn = get(conn, Routes.decorator_type_path(conn, :index))
      assert html_response(conn, 200) =~ "Listing Decorator types"
    end
  end

  describe "new decorator_type" do
    test "renders form", %{conn: conn} do
      conn = get(conn, Routes.decorator_type_path(conn, :new))
      assert html_response(conn, 200) =~ "New Decorator type"
    end
  end

  describe "create decorator_type" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, Routes.decorator_type_path(conn, :create), decorator_type: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.decorator_type_path(conn, :show, id)

      conn = get(conn, Routes.decorator_type_path(conn, :show, id))
      assert html_response(conn, 200) =~ "Show Decorator type"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.decorator_type_path(conn, :create), decorator_type: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Decorator type"
    end
  end

  describe "edit decorator_type" do
    setup [:create_decorator_type]

    test "renders form for editing chosen decorator_type", %{conn: conn, decorator_type: decorator_type} do
      conn = get(conn, Routes.decorator_type_path(conn, :edit, decorator_type))
      assert html_response(conn, 200) =~ "Edit Decorator type"
    end
  end

  describe "update decorator_type" do
    setup [:create_decorator_type]

    test "redirects when data is valid", %{conn: conn, decorator_type: decorator_type} do
      conn = put(conn, Routes.decorator_type_path(conn, :update, decorator_type), decorator_type: @update_attrs)
      assert redirected_to(conn) == Routes.decorator_type_path(conn, :show, decorator_type)

      conn = get(conn, Routes.decorator_type_path(conn, :show, decorator_type))
      assert html_response(conn, 200) =~ "some updated name"
    end

    test "renders errors when data is invalid", %{conn: conn, decorator_type: decorator_type} do
      conn = put(conn, Routes.decorator_type_path(conn, :update, decorator_type), decorator_type: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Decorator type"
    end
  end

  describe "delete decorator_type" do
    setup [:create_decorator_type]

    test "deletes chosen decorator_type", %{conn: conn, decorator_type: decorator_type} do
      conn = delete(conn, Routes.decorator_type_path(conn, :delete, decorator_type))
      assert redirected_to(conn) == Routes.decorator_type_path(conn, :index)
      assert_error_sent 404, fn ->
        get(conn, Routes.decorator_type_path(conn, :show, decorator_type))
      end
    end
  end

  defp create_decorator_type(_) do
    decorator_type = fixture(:decorator_type)
    {:ok, decorator_type: decorator_type}
  end
end
