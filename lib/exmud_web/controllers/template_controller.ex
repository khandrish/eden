defmodule ExmudWeb.TemplateController do
  use ExmudWeb, :controller

  alias Exmud.Template

  def index(conn, _params) do
    templates = Template.list_templates()
    render(conn, "index.html", templates: templates)
  end

  def new(conn, _params) do
    changeset = Template.change_template(%Template.Template{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"template" => template_params}) do
    case Template.create_template(template_params) do
      {:ok, template} ->
        conn
        |> put_flash(:info, "Template created successfully.")
        |> redirect(to: Routes.template_path(conn, :show, template))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    template = Template.get_template!(id)
    callbacks = Template.list_template_callbacks(id)
    render(conn, "show.html", template: template, callbacks: callbacks)
  end

  def edit(conn, %{"id" => id}) do
    live_render(conn, ExmudWeb.TemplateEditLive, session: %{template_id: id})
  end

  def update(conn, %{"id" => id, "template" => template_params}) do
    template = Template.get_template!(id)

    case Template.update_template(template, template_params) do
      {:ok, template} ->
        conn
        |> put_flash(:info, "Template updated successfully.")
        |> redirect(to: Routes.template_path(conn, :show, template))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", template: template, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    template = Template.get_template!(id)
    {:ok, _template} = Template.delete_template(template)

    conn
    |> put_flash(:info, "Template deleted successfully.")
    |> redirect(to: Routes.template_path(conn, :index))
  end
end
