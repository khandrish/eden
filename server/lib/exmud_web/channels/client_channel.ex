defmodule ExmudWeb.ClientChannel do
  @moduledoc """
  The mud client/ui talks to the server over this channel.
  """
  use Phoenix.Channel

  def join("client", %{token: _session_token}, socket) do
    # extract user id from valid token otherwise error
    if Map.get(socket.assigns, :user_id, nil) == String.to_integer("1") do
      # start or reconnect to a mud using a user_id
      {:ok, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end
end
