defmodule ExmudWeb.TemplateCategoryControllerTest do
  use ExmudWeb.ConnCase

  alias Exmud.Template

  @create_attrs %{name: "some name"}
  @update_attrs %{name: "some updated name"}
  @invalid_attrs %{name: nil}

  def fixture(:template_category) do
    {:ok, template_category} = Template.create_template_category(@create_attrs)
    template_category
  end

  describe "index" do
    test "lists all template_categories", %{conn: conn} do
      conn = get(conn, Routes.template_category_path(conn, :index))
      assert html_response(conn, 200) =~ "Listing Template categories"
    end
  end

  describe "new template_category" do
    test "renders form", %{conn: conn} do
      conn = get(conn, Routes.template_category_path(conn, :new))
      assert html_response(conn, 200) =~ "New Template category"
    end
  end

  describe "create template_category" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, Routes.template_category_path(conn, :create), template_category: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.template_category_path(conn, :show, id)

      conn = get(conn, Routes.template_category_path(conn, :show, id))
      assert html_response(conn, 200) =~ "Show Template category"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.template_category_path(conn, :create), template_category: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Template category"
    end
  end

  describe "edit template_category" do
    setup [:create_template_category]

    test "renders form for editing chosen template_category", %{conn: conn, template_category: template_category} do
      conn = get(conn, Routes.template_category_path(conn, :edit, template_category))
      assert html_response(conn, 200) =~ "Edit Template category"
    end
  end

  describe "update template_category" do
    setup [:create_template_category]

    test "redirects when data is valid", %{conn: conn, template_category: template_category} do
      conn = put(conn, Routes.template_category_path(conn, :update, template_category), template_category: @update_attrs)
      assert redirected_to(conn) == Routes.template_category_path(conn, :show, template_category)

      conn = get(conn, Routes.template_category_path(conn, :show, template_category))
      assert html_response(conn, 200) =~ "some updated name"
    end

    test "renders errors when data is invalid", %{conn: conn, template_category: template_category} do
      conn = put(conn, Routes.template_category_path(conn, :update, template_category), template_category: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Template category"
    end
  end

  describe "delete template_category" do
    setup [:create_template_category]

    test "deletes chosen template_category", %{conn: conn, template_category: template_category} do
      conn = delete(conn, Routes.template_category_path(conn, :delete, template_category))
      assert redirected_to(conn) == Routes.template_category_path(conn, :index)
      assert_error_sent 404, fn ->
        get(conn, Routes.template_category_path(conn, :show, template_category))
      end
    end
  end

  defp create_template_category(_) do
    template_category = fixture(:template_category)
    {:ok, template_category: template_category}
  end
end
