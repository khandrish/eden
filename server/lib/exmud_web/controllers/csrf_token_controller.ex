defmodule ExmudWeb.CsrfTokenController do
  use ExmudWeb, :controller

  action_fallback ExmudWeb.FallbackController

  def get_token(conn, _) do
    conn
    |> resp(200, get_csrf_token())
    |> send_resp()
  end
end
