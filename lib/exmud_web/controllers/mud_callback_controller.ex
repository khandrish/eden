defmodule ExmudWeb.MudCallbackController do
  use ExmudWeb, :controller

  alias Exmud.Engine

  def show(conn, %{"id" => id}) do
    mud_callback = Engine.get_mud_callback!(id)
    render(conn, "show.html", mud_callback: mud_callback)
  end

  def edit(conn, %{"id" => id}) do
    mud_callback = Engine.get_mud_callback!(id)
    changeset = Engine.change_mud_callback(mud_callback)

    render(conn, "edit.html",
      mud_callback: mud_callback,
      changeset: changeset,
      docs: Exmud.Util.get_module_docs(mud_callback.callback.module),
      default_config: Poison.encode!(mud_callback.default_config),
      config_schema: Poison.encode!(mud_callback.callback.module.config_schema()),
      has_default_config_error?: false
    )
  end

  def update(conn, %{"id" => id, "mud_callback" => mud_callback_params}) do
    mud_callback = Engine.get_mud_callback!(id)

    with {:ok, config} <- extract_config(mud_callback_params),
         :ok <-
           mud_callback.callback.module.config_schema()
           |> ExJsonSchema.Schema.resolve()
           |> ExJsonSchema.Validator.validate(config),
         mud_callback_params <-
           Map.put(mud_callback_params, "default_config", config),
         {:ok, _mud_callback} <-
           Engine.update_mud_callback(mud_callback, mud_callback_params) do
      conn
      |> put_flash(:info, "Mud callback updated successfully.")
      |> redirect(to: NavigationHistory.last_path(conn, 1))
    else
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html",
          mud_callback: mud_callback,
          changeset: changeset,
          docs: Exmud.Util.get_module_docs(mud_callback.callback.module),
          default_config: Poison.encode!(mud_callback.default_config),
          config_schema: Poison.encode!(mud_callback.module.config_schema()),
          has_default_config_error?: true
        )

      {:error, :invalid_json} ->
        conn
        |> put_flash(:error, "Invalid JSON submitted.")
        |> render("edit.html",
          mud_callback: mud_callback,
          changeset: Engine.change_mud_callback(mud_callback),
          docs: Exmud.Util.get_module_docs(mud_callback.callback.module),
          default_config: Poison.encode!(mud_callback.default_config),
          config_schema: Poison.encode!(mud_callback.callback.module.config_schema()),
          has_default_config_error?: true
        )

      {:error, errors} ->
        {:ok, config} = extract_config(mud_callback_params)
        errors = Exmud.Util.exjson_validator_errors_to_changeset_errors(:default_config, errors)
        changeset = Engine.change_mud_callback(mud_callback)

        changeset = %{
          changeset
          | errors: Keyword.merge(changeset.errors, errors),
            valid?: false,
            action: :insert
        }

        render(conn, "edit.html",
          mud_callback: mud_callback,
          changeset: changeset,
          docs: Exmud.Util.get_module_docs(mud_callback.callback.module),
          default_config: Poison.encode!(config),
          config_schema: Poison.encode!(mud_callback.callback.module.config_schema()),
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
