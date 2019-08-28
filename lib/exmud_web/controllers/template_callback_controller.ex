defmodule ExmudWeb.TemplateCallbackController do
  use ExmudWeb, :controller

  alias Exmud.Template

  def show(conn, %{"id" => id}) do
    template_callback = Template.get_template_callback!(id)
    render(conn, "show.html", template_callback: template_callback)
  end

  def edit(conn, %{"id" => id}) do
    template_callback = Template.get_template_callback!(id)
    changeset = Template.change_template_callback(template_callback)

    render(conn, "edit.html",
      template_callback: template_callback,
      changeset: changeset,
      docs: Exmud.Util.get_module_docs(template_callback.callback.module),
      default_config: Poison.encode!(template_callback.default_config),
      config_schema: Poison.encode!(template_callback.callback.module.config_schema()),
      has_default_config_error?: false
    )
  end

  def update(conn, %{"id" => id, "template_callback" => template_callback_params}) do
    template_callback = Template.get_template_callback!(id)

    with {:ok, config} <- extract_config(template_callback_params),
         :ok <-
           template_callback.callback.module.config_schema()
           |> ExJsonSchema.Schema.resolve()
           |> ExJsonSchema.Validator.validate(config),
         template_callback_params <-
           Map.put(template_callback_params, "default_config", config),
         {:ok, _template_callback} <-
           Template.update_template_callback(template_callback, template_callback_params) do
      conn
      |> put_flash(:info, "Template callback updated successfully.")
      |> redirect(to: NavigationHistory.last_path(conn, 1))
    else
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html",
          template_callback: template_callback,
          changeset: changeset,
          docs: Exmud.Util.get_module_docs(template_callback.callback.module),
          default_config: Poison.encode!(template_callback.default_config),
          config_schema: Poison.encode!(template_callback.module.config_schema()),
          has_default_config_error?: true
        )

      {:error, :invalid_json} ->
        conn
        |> put_flash(:error, "Invalid JSON submitted.")
        |> render("edit.html",
          template_callback: template_callback,
          changeset: Template.change_template_callback(template_callback),
          docs: Exmud.Util.get_module_docs(template_callback.callback.module),
          default_config: Poison.encode!(template_callback.default_config),
          config_schema: Poison.encode!(template_callback.callback.module.config_schema()),
          has_default_config_error?: true
        )

      {:error, errors} ->
        {:ok, config} = extract_config(template_callback_params)
        errors = Exmud.Util.exjson_validator_errors_to_changeset_errors(:default_config, errors)
        changeset = Template.change_template_callback(template_callback)

        changeset = %{
          changeset
          | errors: Keyword.merge(changeset.errors, errors),
            valid?: false,
            action: :insert
        }

        render(conn, "edit.html",
          template_callback: template_callback,
          changeset: changeset,
          docs: Exmud.Util.get_module_docs(template_callback.callback.module),
          default_config: Poison.encode!(config),
          config_schema: Poison.encode!(template_callback.callback.module.config_schema()),
          has_default_config_error?: true
        )
    end
  end

  defp extract_config(params) do
    case Poison.decode(params["updated_default_config"]) do
      {:ok, updated_config} ->
        {:ok, updated_config}

      {:error, _} ->
        {:error, :invalid_json}
    end
  end
end
