defmodule ExmudWeb.TemplateController do
  use ExmudWeb, :controller

  alias Exmud.Builder
  alias Exmud.Builder.Template

  def index(conn, %{"mud_slug" => mud_slug}) do
    categories = Builder.list_categories()
    render(conn, "index.html", mud_slug: mud_slug, categories: categories)
  end

  def new(conn, %{"mud_slug" => mud_slug}) do
    changeset = Builder.change_template(%Template{})
    render(conn, "new.html", mud_slug: mud_slug, changeset: changeset)
  end

  def create(conn, %{"template" => template_params, "mud_slug" => mud_slug}) do
    case Builder.create_template(template_params) do
      {:ok, template} ->
        conn
        |> put_flash(:info, "Template created successfully.")
        |> redirect(to: Routes.mud_template_path(conn, :show, mud_slug, template))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", mud_slug: mud_slug, changeset: changeset)
    end
  end

  def show(conn, %{"id" => id, "mud_slug" => mud_slug}) do
    template = Builder.get_template!(id)
    render(conn, "show.html", mud_slug: mud_slug, template: template)
  end

  def edit(conn, %{"id" => id, "mud_slug" => mud_slug}) do
    template = Builder.get_template!(id)
    changeset = Builder.change_template(template)

    render(conn, "edit.html",
      mud_slug: mud_slug,
      template: template,
      changeset: changeset
    )
  end

  def update(conn, %{"id" => id, "template" => template_params, "mud_slug" => mud_slug}) do
    template = Builder.get_template!(id)

    case Builder.update_template(template, template_params) do
      {:ok, template} ->
        conn
        |> put_flash(:info, "Template updated successfully.")
        |> redirect(to: Routes.mud_template_path(conn, :show, template, mud_slug))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html",
          mud_slug: mud_slug,
          template: template,
          changeset: changeset
        )
    end
  end

  def delete(conn, %{"id" => id, "mud_slug" => mud_slug}) do
    template = Builder.get_template!(id)
    {:ok, _template} = Builder.delete_template(template)

    conn
    |> put_flash(:info, "Template deleted successfully.")
    |> redirect(to: Routes.mud_template_path(conn, :create, mud_slug))
  end
end
