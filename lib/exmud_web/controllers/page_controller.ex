defmodule ExmudWeb.PageController do
  use ExmudWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html", player_authenticated?: conn.assigns.player_authenticated?)
  end
end
