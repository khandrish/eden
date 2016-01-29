defmodule Eden.Plug.EnsureAllParams do
  @moduledoc """
    EnsureAllParams plug can be used to make sure none of the
    required_params params sent in with the request are missing.
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