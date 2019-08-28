defmodule ExmudWeb.TemplateTypeControllerTest do
  use ExmudWeb.ConnCase

  alias Exmud.Template

  @create_attrs %{name: "some name"}
  @update_attrs %{name: "some updated name"}
  @invalid_attrs %{name: nil}

  def fixture(:template_type) do
    {:ok, template_type} = Template.create_template_type(@create_attrs)
    template_type
  end

  describe "index" do
    test "lists all template_types", %{conn: conn} do
      conn = get(conn, Routes.template_type_path(conn, :index))
      assert html_response(conn, 200) =~ "Listing Template types"
    end
  end

  describe "new template_type" do
    test "renders form", %{conn: conn} do
      conn = get(conn, Routes.template_type_path(conn, :new))
      assert html_response(conn, 200) =~ "New Template type"
    end
  end

  describe "create template_type" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, Routes.template_type_path(conn, :create), template_type: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.template_type_path(conn, :show, id)

      conn = get(conn, Routes.template_type_path(conn, :show, id))
      assert html_response(conn, 200) =~ "Show Template type"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.template_type_path(conn, :create), template_type: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Template type"
    end
  end

  describe "edit template_type" do
    setup [:create_template_type]

    test "renders form for editing chosen template_type", %{conn: conn, template_type: template_type} do
      conn = get(conn, Routes.template_type_path(conn, :edit, template_type))
      assert html_response(conn, 200) =~ "Edit Template type"
    end
  end

  describe "update template_type" do
    setup [:create_template_type]

    test "redirects when data is valid", %{conn: conn, template_type: template_type} do
      conn = put(conn, Routes.template_type_path(conn, :update, template_type), template_type: @update_attrs)
      assert redirected_to(conn) == Routes.template_type_path(conn, :show, template_type)

      conn = get(conn, Routes.template_type_path(conn, :show, template_type))
      assert html_response(conn, 200) =~ "some updated name"
    end

    test "renders errors when data is invalid", %{conn: conn, template_type: template_type} do
      conn = put(conn, Routes.template_type_path(conn, :update, template_type), template_type: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Template type"
    end
  end

  describe "delete template_type" do
    setup [:create_template_type]

    test "deletes chosen template_type", %{conn: conn, template_type: template_type} do
      conn = delete(conn, Routes.template_type_path(conn, :delete, template_type))
      assert redirected_to(conn) == Routes.template_type_path(conn, :index)
      assert_error_sent 404, fn ->
        get(conn, Routes.template_type_path(conn, :show, template_type))
      end
    end
  end

  defp create_template_type(_) do
    template_type = fixture(:template_type)
    {:ok, template_type: template_type}
  end
end
