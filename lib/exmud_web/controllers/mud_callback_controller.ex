defmodule ExmudWeb.MudCallbackController do
  use ExmudWeb, :controller

  alias Exmud.Builder
  alias Exmud.Engine

  defmodule CallbackGroups do
    @moduledoc false
    defstruct commands: [],
              command_sets: [],
              components: [],
              links: [],
              locks: [],
              scripts: [],
              systems: []
  end

  def show(conn, %{"id" => id}) do
    mud_callback = Builder.get_mud_callback!(id)
    render(conn, "show.html", mud_callback: mud_callback)
  end

  def list(conn, %{"id" => id}) do
    mud_callbacks = Builder.list_mud_callbacks(id)
    grouped_callbacks = populate_callback_groups(mud_callbacks)
    render(conn, "show.html", grouped_callbacks: grouped_callbacks)
  end

  def edit(conn, %{"id" => id}) do
    mud_callback = Builder.get_mud_callback!(id)
    changeset = Builder.change_mud_callback(mud_callback)

    render(conn, "edit.html",
      mud_callback: mud_callback,
      changeset: changeset,
      docs: Exmud.Util.get_module_docs(mud_callback.callback.module),
      config: Poison.encode!(mud_callback.config),
      config_schema: Poison.encode!(mud_callback.callback.module.config_schema()),
      has_config_error?: false
    )
  end

  def update(conn, %{"id" => id, "mud_callback" => mud_callback_params}) do
    mud_callback = Builder.get_mud_callback!(id)

    with {:ok, config} <- extract_config(mud_callback_params),
         :ok <-
           mud_callback.callback.module.config_schema()
           |> ExJsonSchema.Schema.resolve()
           |> ExJsonSchema.Validator.validate(config),
         mud_callback_params <-
           Map.put(mud_callback_params, "config", config),
         {:ok, _mud_callback} <-
           Builder.update_mud_callback(mud_callback, mud_callback_params) do
      last_path = NavigationHistory.last_path(conn, 1)

      path =
        if String.contains?(last_path, "show") do
          "#{last_path}##{mud_callback.callback.type}s"
        else
          last_path
        end

      conn
      |> put_flash(:info, "Engine callback updated successfully.")
      |> redirect(to: path)
    else
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html",
          mud_callback: mud_callback,
          changeset: changeset,
          docs: Exmud.Util.get_module_docs(mud_callback.callback.module),
          config: Poison.encode!(mud_callback.config),
          config_schema: Poison.encode!(mud_callback.module.config_schema()),
          has_config_error?: true
        )

      {:error, :invalid_json} ->
        conn
        |> put_flash(:error, "Invalid JSON submitted.")
        |> render("edit.html",
          mud_callback: mud_callback,
          changeset: Builder.change_mud_callback(mud_callback),
          docs: Exmud.Util.get_module_docs(mud_callback.callback.module),
          config: Poison.encode!(mud_callback.config),
          config_schema: Poison.encode!(mud_callback.callback.module.config_schema()),
          has_config_error?: true
        )

      {:error, errors} ->
        {:ok, config} = extract_config(mud_callback_params)
        errors = Exmud.Util.exjson_validator_errors_to_changeset_errors(:config, errors)
        changeset = Builder.change_mud_callback(mud_callback)

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
          config: Poison.encode!(config),
          config_schema: Poison.encode!(mud_callback.callback.module.config_schema()),
          has_config_error?: true
        )
    end
  end

  defp extract_config(params) do
    case Poison.decode(params["updated_config"]) do
      {:ok, updated_config} ->
        {:ok, updated_config}

      {:error, _} ->
        {:error, :invalid_json}
    end
  end

  defp populate_callback_groups(callbacks) do
    Enum.reduce(callbacks, %CallbackGroups{}, fn callback, groups ->
      key = String.to_existing_atom("#{callback.callback.type}s")
      Map.update!(groups, key, fn existing_callbacks -> existing_callbacks ++ [callback] end)
    end)
  end
end
