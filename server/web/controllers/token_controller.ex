defmodule Eden.TokenController do
  use Eden.Web, :controller

  def get_token(conn, _params) do
  	result = conn.cookies["foo"]
  	IO.inspect result
  	IO.inspect "foo"
  	uuid = Ecto.UUID.generate
  	token = Phoenix.Token.sign(conn, "player", uuid)
    json conn, %{token: token, session_id: uuid}
  end
end
