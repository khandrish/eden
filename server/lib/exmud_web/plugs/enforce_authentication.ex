defmodule ExmudWeb.Plug.EnforceAuthentication do
  import Plug.Conn

  def init(_params) do
  end

  def call(conn, _params) do
    IO.inspect(conn.assigns)
    if conn.assigns.player_authenticated? do
      conn
    else
      conn
      |> put_status(401)
      |> Phoenix.Controller.put_view(ExmudWeb.ErrorView)
      |> Phoenix.Controller.render("401.json")
      |> halt()
    end
  end
end
