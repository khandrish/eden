defmodule ExmudWeb.Plug.EnforceAuthentication do
  import Plug.Conn

  def init(_params) do
  end

  def call(conn, _params) do
    if conn.assigns.player_authenticated? do
      conn
    else
      conn
      |> put_status(401)
      |> send_resp()
    end
  end
end
