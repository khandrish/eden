defmodule Exmud.Portal.Web.PageController do
  use Exmud.Portal.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
