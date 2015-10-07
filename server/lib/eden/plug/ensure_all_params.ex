defmodule Eden.Plug.EnsureAllParams do
  @moduledoc """
    Authenticated plug can be used ensure an action can only be triggered by
    players that are authenticated.
  """
  import Plug.Conn

  def init(required_params) do
    required_params
  end

  def call(%Plug.Conn{params: params} = conn, required_params) do
    cond do
      Enum.all?(required_params, fn(key) ->
        Map.has_key?(params, key)
      end) ->
        conn
      true ->
        conn
        |> halt
        |> send_resp(:bad_request, "")
    end
  end
end