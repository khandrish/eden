defmodule Eden.TokenController do
  use Eden.Web, :controller

  plug Eden.Plug.Authenticated when action in [:token]

  def token(conn, _params) do
    json conn, %{token: Phoenix.Token.sign(conn, "player", conn.assigns[:current_player].id)}
  end
end
