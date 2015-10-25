defmodule Eden.Plug.EnsurePopulatedParams do
  @moduledoc """
    EnsurePopulatedParams plug can be used to make sure none of the
    required_params params sent in with the request are empty.
  """
  import Plug.Conn

  def init(required_params) do
    required_params
  end

  def call(%Plug.Conn{params: params} = conn, required_params) do
    cond do
      Enum.all?(params, fn({key, value}) ->
        if key in required_params do
          if Map.get(params, key) != nil do
            true
          else
            false
          end
        else
          true
        end
      end) ->
        conn
      true ->
        conn
        |> halt
        |> send_resp(:unprocessable_entity, "")
    end
  end
end