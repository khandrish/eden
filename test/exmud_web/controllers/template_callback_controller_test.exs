defmodule ExmudWeb.TemplateCallbackControllerTest do
  use ExmudWeb.ConnCase

  alias Exmud.Engine

  @create_attrs %{default_args: "some default_args"}
  @update_attrs %{default_args: "some updated default_args"}
  @invalid_attrs %{default_args: nil}

  def fixture(:template_callback) do
    {:ok, template_callback} = Engine.create_template_callback(@create_attrs)
    template_callback
  end

  describe "index" do
    test "lists all template_callbacks", %{conn: conn} do
      conn = get(conn, Routes.template_callback_path(conn, :index))
      assert html_response(conn, 200) =~ "Listing Template callbacks"
    end
  end

  describe "new template_callback" do
    test "renders form", %{conn: conn} do
      conn = get(conn, Routes.template_callback_path(conn, :new))
      assert html_response(conn, 200) =~ "New Template callback"
    end
  end

  describe "create template_callback" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, Routes.template_callback_path(conn, :create), template_callback: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.template_callback_path(conn, :show, id)

      conn = get(conn, Routes.template_callback_path(conn, :show, id))
      assert html_response(conn, 200) =~ "Show Template callback"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.template_callback_path(conn, :create), template_callback: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Template callback"
    end
  end

  describe "edit template_callback" do
    setup [:create_template_callback]

    test "renders form for editing chosen template_callback", %{conn: conn, template_callback: template_callback} do
      conn = get(conn, Routes.template_callback_path(conn, :edit, template_callback))
      assert html_response(conn, 200) =~ "Edit Template callback"
    end
  end

  describe "update template_callback" do
    setup [:create_template_callback]

    test "redirects when data is valid", %{conn: conn, template_callback: template_callback} do
      conn = put(conn, Routes.template_callback_path(conn, :update, template_callback), template_callback: @update_attrs)
      assert redirected_to(conn) == Routes.template_callback_path(conn, :show, template_callback)

      conn = get(conn, Routes.template_callback_path(conn, :show, template_callback))
      assert html_response(conn, 200)
    end

    test "renders errors when data is invalid", %{conn: conn, template_callback: template_callback} do
      conn = put(conn, Routes.template_callback_path(conn, :update, template_callback), template_callback: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Template callback"
    end
  end

  describe "delete template_callback" do
    setup [:create_template_callback]

    test "deletes chosen template_callback", %{conn: conn, template_callback: template_callback} do
      conn = delete(conn, Routes.template_callback_path(conn, :delete, template_callback))
      assert redirected_to(conn) == Routes.template_callback_path(conn, :index)
      assert_error_sent 404, fn ->
        get(conn, Routes.template_callback_path(conn, :show, template_callback))
      end
    end
  end

  defp create_template_callback(_) do
    template_callback = fixture(:template_callback)
    {:ok, template_callback: template_callback}
  end
end
