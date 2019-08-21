defmodule ExmudWeb.TemplateControllerTest do
  use ExmudWeb.ConnCase

  alias Exmud.Engine

  @create_attrs %{name: "some name"}
  @update_attrs %{name: "some updated name"}
  @invalid_attrs %{name: nil}

  def fixture(:template) do
    {:ok, template} = Engine.create_template(@create_attrs)
    template
  end

  describe "index" do
    test "lists all templates", %{conn: conn} do
      conn = get(conn, Routes.template_path(conn, :index))
      assert html_response(conn, 200) =~ "Listing Templates"
    end
  end

  describe "new template" do
    test "renders form", %{conn: conn} do
      conn = get(conn, Routes.template_path(conn, :new))
      assert html_response(conn, 200) =~ "New Template"
    end
  end

  describe "create template" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, Routes.template_path(conn, :create), template: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.template_path(conn, :show, id)

      conn = get(conn, Routes.template_path(conn, :show, id))
      assert html_response(conn, 200) =~ "Show Template"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.template_path(conn, :create), template: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Template"
    end
  end

  describe "edit template" do
    setup [:create_template]

    test "renders form for editing chosen template", %{conn: conn, template: template} do
      conn = get(conn, Routes.template_path(conn, :edit, template))
      assert html_response(conn, 200) =~ "Edit Template"
    end
  end

  describe "update template" do
    setup [:create_template]

    test "redirects when data is valid", %{conn: conn, template: template} do
      conn = put(conn, Routes.template_path(conn, :update, template), template: @update_attrs)
      assert redirected_to(conn) == Routes.template_path(conn, :show, template)

      conn = get(conn, Routes.template_path(conn, :show, template))
      assert html_response(conn, 200)
    end

    test "renders errors when data is invalid", %{conn: conn, template: template} do
      conn = put(conn, Routes.template_path(conn, :update, template), template: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Template"
    end
  end

  describe "delete template" do
    setup [:create_template]

    test "deletes chosen template", %{conn: conn, template: template} do
      conn = delete(conn, Routes.template_path(conn, :delete, template))
      assert redirected_to(conn) == Routes.template_path(conn, :index)
      assert_error_sent 404, fn ->
        get(conn, Routes.template_path(conn, :show, template))
      end
    end
  end

  defp create_template(_) do
    template = fixture(:template)
    {:ok, template: template}
  end
end
