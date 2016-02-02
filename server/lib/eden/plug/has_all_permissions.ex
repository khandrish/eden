defmodule Eden.Plug.HasAllPermissions do
  @moduledoc """
    Authenticated plug can be used ensure an action can only be triggered by
    players that are authenticated.
  """
  import Plug.Conn

  def init(default) do
    default
  end

  def call(%Plug.Conn{assigns: %{current_player: player}} = conn, permissions) do
    cond do
      Enum.all?(permissions, fn(permission) ->
        case permission do
          "self" ->
            if player.id == Map.get(conn.params, "id") do
              true
            else
              false
            end
          _ ->
            true
        end
      end) ->
        conn
      true ->
        conn
        |> halt
        |> send_resp(:unauthorized, "[\"Not authorized.\"]")
    end
  end
end