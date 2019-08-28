defmodule ExmudWeb.TemplateCategoryController do
  use ExmudWeb, :controller

  alias Exmud.Template
  alias Exmud.Template.TemplateCategory

  def new(conn, _params) do
    changeset = Template.change_template_category(%TemplateCategory{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"template_category" => template_category_params}) do
    case Template.create_template_category(template_category_params) do
      {:ok, template_category} ->
        conn
        |> put_flash(:info, "Template category created successfully.")
        |> redirect(to: Routes.template_category_path(conn, :show, template_category))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    template_category = Template.get_template_category!(id)
    render(conn, "show.html", template_category: template_category)
  end

  def edit(conn, %{"id" => id}) do
    template_category = Template.get_template_category!(id)
    changeset = Template.change_template_category(template_category)
    render(conn, "edit.html", template_category: template_category, changeset: changeset)
  end

  def update(conn, %{"id" => id, "template_category" => template_category_params}) do
    template_category = Template.get_template_category!(id)

    case Template.update_template_category(template_category, template_category_params) do
      {:ok, template_category} ->
        conn
        |> put_flash(:info, "Template category updated successfully.")
        |> redirect(to: Routes.template_category_path(conn, :show, template_category))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", template_category: template_category, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    template_category = Template.get_template_category!(id)
    {:ok, _template_category} = Template.delete_template_category(template_category)

    conn
    |> put_flash(:info, "Template category deleted successfully.")
    |> redirect(to: Routes.template_category_path(conn, :index))
  end
end
