defmodule Eden.Plug.EnsurePopulatedParams do
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