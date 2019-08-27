defmodule ExmudWeb.MudController do
  use ExmudWeb, :controller

  alias Exmud.Engine
  alias Exmud.Engine.Mud

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

  def index(conn, _params) do
    muds = Engine.list_muds()
    render(conn, "index.html", muds: muds)
  end

  def new(conn, _params) do
    changeset = Engine.change_mud(%Mud{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"mud" => mud_params}) do
    case Engine.create_mud(mud_params) do
      {:ok, mud} ->
        conn
        |> put_flash(:info, "Mud created successfully.")
        |> redirect(to: Routes.mud_path(conn, :show, mud))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    mud = Engine.get_mud!(id)
    callbacks = Engine.list_mud_callbacks(id)
    grouped_callbacks = populate_callback_groups(callbacks)
    templates = Engine.list_templates(id)

    show = Map.get(conn.query_params, "show")

    render(conn, "show.html",
      mud: mud,
      grouped_callbacks: grouped_callbacks,
      show: show,
      templates: templates
    )
  end

  def edit(conn, %{"id" => id}) do
    mud = Engine.get_mud!(id)

    mud_callback_set =
      Engine.list_mud_callbacks(id)
      |> Enum.reduce(MapSet.new(), fn sc, ms -> MapSet.put(ms, sc.callback_id) end)

    callbacks =
      Engine.list_callbacks()
      |> Enum.map(fn cb ->
        %{callback: cb, present: MapSet.member?(mud_callback_set, cb.id)}
      end)

    grouped_callbacks = populate_callback_groups(callbacks)

    show = Map.get(conn.query_params, "show")

    render(conn, "edit.html",
      grouped_callbacks: grouped_callbacks,
      id: String.to_integer(id),
      mud: mud,
      show: show
    )
  end

  def update(conn, %{"id" => id, "mud" => mud_params}) do
    mud = Engine.get_mud!(id)

    case Engine.update_mud(mud, mud_params) do
      {:ok, mud} ->
        conn
        |> put_flash(:info, "Mud updated successfully.")
        |> redirect(to: Routes.mud_path(conn, :show, mud))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", mud: mud, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    mud = Engine.get_mud!(id)
    {:ok, _mud} = Engine.delete_mud(mud)

    conn
    |> put_flash(:info, "Mud deleted successfully.")
    |> redirect(to: Routes.mud_path(conn, :index))
  end

  defp populate_callback_groups(callbacks) do
    Enum.reduce(callbacks, %CallbackGroups{}, fn callback, groups ->
      key = String.to_existing_atom("#{callback.callback.type}s")
      Map.update!(groups, key, fn existing_callbacks -> existing_callbacks ++ [callback] end)
    end)
  end
end
