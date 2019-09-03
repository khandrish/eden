defmodule ExmudWeb.Plug.AssignSlugs do
  import Plug.Conn

  def init(_params) do
  end

  def call(conn, _params) do
    conn.path_params
    |> Map.keys()
    |> Enum.filter(fn key ->
      String.contains?(key, "slug")
    end)
    |> Enum.reduce(conn, fn key, connection ->
      assign(connection, String.to_existing_atom(key), Map.get(connection.path_params, key))
    end)
  end
end
