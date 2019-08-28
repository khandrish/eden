defmodule ExmudWeb.DecoratorCategoryControllerTest do
  use ExmudWeb.ConnCase

  alias Exmud.Decorator

  @create_attrs %{name: "some name"}
  @update_attrs %{name: "some updated name"}
  @invalid_attrs %{name: nil}

  def fixture(:decorator_category) do
    {:ok, decorator_category} = Decorator.create_decorator_category(@create_attrs)
    decorator_category
  end

  describe "index" do
    test "lists all decorator_categories", %{conn: conn} do
      conn = get(conn, Routes.decorator_category_path(conn, :index))
      assert html_response(conn, 200) =~ "Listing Decorator categories"
    end
  end

  describe "new decorator_category" do
    test "renders form", %{conn: conn} do
      conn = get(conn, Routes.decorator_category_path(conn, :new))
      assert html_response(conn, 200) =~ "New Decorator category"
    end
  end

  describe "create decorator_category" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, Routes.decorator_category_path(conn, :create), decorator_category: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.decorator_category_path(conn, :show, id)

      conn = get(conn, Routes.decorator_category_path(conn, :show, id))
      assert html_response(conn, 200) =~ "Show Decorator category"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.decorator_category_path(conn, :create), decorator_category: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Decorator category"
    end
  end

  describe "edit decorator_category" do
    setup [:create_decorator_category]

    test "renders form for editing chosen decorator_category", %{conn: conn, decorator_category: decorator_category} do
      conn = get(conn, Routes.decorator_category_path(conn, :edit, decorator_category))
      assert html_response(conn, 200) =~ "Edit Decorator category"
    end
  end

  describe "update decorator_category" do
    setup [:create_decorator_category]

    test "redirects when data is valid", %{conn: conn, decorator_category: decorator_category} do
      conn = put(conn, Routes.decorator_category_path(conn, :update, decorator_category), decorator_category: @update_attrs)
      assert redirected_to(conn) == Routes.decorator_category_path(conn, :show, decorator_category)

      conn = get(conn, Routes.decorator_category_path(conn, :show, decorator_category))
      assert html_response(conn, 200) =~ "some updated name"
    end

    test "renders errors when data is invalid", %{conn: conn, decorator_category: decorator_category} do
      conn = put(conn, Routes.decorator_category_path(conn, :update, decorator_category), decorator_category: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Decorator category"
    end
  end

  describe "delete decorator_category" do
    setup [:create_decorator_category]

    test "deletes chosen decorator_category", %{conn: conn, decorator_category: decorator_category} do
      conn = delete(conn, Routes.decorator_category_path(conn, :delete, decorator_category))
      assert redirected_to(conn) == Routes.decorator_category_path(conn, :index)
      assert_error_sent 404, fn ->
        get(conn, Routes.decorator_category_path(conn, :show, decorator_category))
      end
    end
  end

  defp create_decorator_category(_) do
    decorator_category = fixture(:decorator_category)
    {:ok, decorator_category: decorator_category}
  end
end
