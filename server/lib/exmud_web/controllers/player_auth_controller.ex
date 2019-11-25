defmodule ExmudWeb.PlayerAuthController do
  use ExmudWeb, :controller

  alias Exmud.Account

  action_fallback ExmudWeb.FallbackController

  def authenticate_via_email(conn, %{"email" => email}) do
    {:ok, _} = Account.authenticate_via_email(email)

    conn
    |> resp(200, "")
    |> send_resp()
  end

  def logout(conn, _params) do
    conn
    |> clear_session()
    |> resp(200, "")
    |> send_resp()
  end

  def validate_auth_token(conn, %{"token" => token}) do
    case Account.validate_auth_token(token) do
      {:ok, player} ->
        result =
          conn
          |> put_session("player", player)
          |> put_status(:ok)
          |> put_view(ExmudWeb.PlayerView)
          |> render("show.json", player: player)

          IO.inspect(get_session(result))

          result
      _error ->
        conn
        |> resp(401, "invalid token")
        |> send_resp()
    end
  end
end
