defmodule Eden.Plug.JsonApi do
  @moduledoc """
    Makes sure that the json response header is set
  """
  import Plug.Conn

  def init(default) do
    default
  end

  def call(conn, _) do
    conn |> put_resp_content_type("application/json")
  end
end