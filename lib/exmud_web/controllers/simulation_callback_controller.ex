defmodule ExmudWeb.SimulationCallbackController do
  use ExmudWeb, :controller

  alias Exmud.Engine
  alias Exmud.Engine.SimulationCallback

  def create(conn, %{"simulation_callback" => simulation_callback_params}) do
    case Engine.create_simulation_callback(simulation_callback_params) do
      {:ok, simulation_callback} ->
        conn
        |> put_flash(:info, "Simulation callback created successfully.")
        |> redirect(to: Routes.simulation_callback_path(conn, :show, simulation_callback))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    simulation_callback = Engine.get_simulation_callback!(id)
    render(conn, "show.html", simulation_callback: simulation_callback)
  end

  def edit(conn, %{"id" => id}) do
    simulation_callback = Engine.get_simulation_callback!(id)
    changeset = Engine.change_simulation_callback(simulation_callback)

    render(conn, "edit.html",
      simulation_callback: simulation_callback,
      changeset: changeset,
      docs: Exmud.Util.get_module_docs(simulation_callback.callback.module),
      default_config: Poison.encode!(simulation_callback.default_config),
      config_schema: Poison.encode!(simulation_callback.callback.module.config_schema()),
      has_default_config_error?: false
    )
  end

  def update(conn, %{"id" => id, "simulation_callback" => simulation_callback_params}) do
    simulation_callback = Engine.get_simulation_callback!(id)
    IO.inspect(simulation_callback.callback.module.config_schema())
    IO.inspect(simulation_callback_params)

    with {:ok, config} <- extract_config(simulation_callback_params),
         :ok <-
           simulation_callback.callback.module.config_schema()
           |> ExJsonSchema.Schema.resolve()
           |> ExJsonSchema.Validator.validate(config),
         simulation_callback_params <-
           Map.put(simulation_callback_params, "default_config", config),
         {:ok, _simulation_callback} <-
           Engine.update_simulation_callback(simulation_callback, simulation_callback_params) do
      conn
      |> put_flash(:info, "Simulation callback updated successfully.")
      |> redirect(to: NavigationHistory.last_path(conn, 1))
    else
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html",
          simulation_callback: simulation_callback,
          changeset: changeset,
          docs: Exmud.Util.get_module_docs(simulation_callback.callback.module),
          default_config: Poison.encode!(simulation_callback.default_config),
          config_schema: Poison.encode!(simulation_callback.module.config_schema()),
          has_default_config_error?: true
        )

      {:error, :invalid_json} ->
        conn
        |> put_flash(:error, "Invalid JSON submitted.")
        |> render("edit.html",
          simulation_callback: simulation_callback,
          changeset: Engine.change_simulation_callback(simulation_callback),
          docs: Exmud.Util.get_module_docs(simulation_callback.callback.module),
          default_config: Poison.encode!(simulation_callback.default_config),
          config_schema: Poison.encode!(simulation_callback.callback.module.config_schema()),
          has_default_config_error?: true
        )

      {:error, errors} ->
        {:ok, config} = extract_config(simulation_callback_params)
        errors = Exmud.Util.exjson_validator_errors_to_changeset_errors(:default_config, errors)
        changeset = Engine.change_simulation_callback(simulation_callback)

        changeset = %{
          changeset
          | errors: Keyword.merge(changeset.errors, errors),
            valid?: false,
            action: :insert
        }

        render(conn, "edit.html",
          simulation_callback: simulation_callback,
          changeset: changeset,
          docs: Exmud.Util.get_module_docs(simulation_callback.callback.module),
          default_config: Poison.encode!(config),
          config_schema: Poison.encode!(simulation_callback.callback.module.config_schema()),
          has_default_config_error?: true
        )
    end
  end

  def delete(conn, %{"id" => id}) do
    simulation_callback = Engine.get_simulation_callback!(id)
    {:ok, _simulation_callback} = Engine.delete_simulation_callback(simulation_callback)

    conn
    |> put_flash(:info, "Simulation callback deleted successfully.")
    |> redirect(to: Routes.simulation_callback_path(conn, :index))
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
