defmodule ExmudWeb.TemplateTypeController do
  use ExmudWeb, :controller

  alias Exmud.Template
  alias Exmud.Template.TemplateType

  def new(conn, _params) do
    changeset = Template.change_template_type(%TemplateType{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"template_type" => template_type_params}) do
    case Template.create_template_type(template_type_params) do
      {:ok, template_type} ->
        conn
        |> put_flash(:info, "Template type created successfully.")
        |> redirect(to: Routes.template_type_path(conn, :show, template_type))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    template_type = Template.get_template_type!(id)
    render(conn, "show.html", template_type: template_type)
  end

  def edit(conn, %{"id" => id}) do
    template_type = Template.get_template_type!(id)
    changeset = Template.change_template_type(template_type)
    render(conn, "edit.html", template_type: template_type, changeset: changeset)
  end

  def update(conn, %{"id" => id, "template_type" => template_type_params}) do
    template_type = Template.get_template_type!(id)

    case Template.update_template_type(template_type, template_type_params) do
      {:ok, template_type} ->
        conn
        |> put_flash(:info, "Template type updated successfully.")
        |> redirect(to: Routes.template_type_path(conn, :show, template_type))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", template_type: template_type, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    template_type = Template.get_template_type!(id)
    {:ok, _template_type} = Template.delete_template_type(template_type)

    conn
    |> put_flash(:info, "Template type deleted successfully.")
    |> redirect(to: Routes.template_type_path(conn, :index))
  end
end
