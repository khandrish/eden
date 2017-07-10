defmodule Exmud.Web.PageController do
  use Exmud.Web.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
