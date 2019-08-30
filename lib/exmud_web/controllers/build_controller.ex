defmodule ExmudWeb.BuildController do
  use ExmudWeb, :controller

  alias Exmud.Engine

  @spec index(Plug.Conn.t(), map) :: Plug.Conn.t()
  def index(conn, _params) do
    muds = Engine.list_muds()

    render(conn, "index.html", muds: muds)
  end

  @spec show(Plug.Conn.t(), map) :: Plug.Conn.t()
  def show(conn, %{"slug" => slug}) do
    mud = Engine.get_mud_by_slug!(slug)

    render(conn, "show.html",
      mud: mud,
      layout: {ExmudWeb.LayoutView, "left_side_nav.html"},
      side_nav_links: side_nav_links(conn, slug)
    )
  end

  defp side_nav_links(conn, slug) do
    [
      %{
        disabled?: false,
        path: Routes.mud_prototype_path(conn, :index, slug),
        text: "Prototypes"
      },
      %{
        disabled?: false,
        path: Routes.mud_template_path(conn, :index, slug),
        text: "Templates"
      },
      %{
        disabled?: false,
        path: Routes.mud_category_path(conn, :index, slug),
        text: "Categories"
      }
    ]
  end
end
