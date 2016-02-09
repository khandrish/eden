defmodule Eden.PlayerSocket do
  use Phoenix.Socket

  alias Phoenix.Token
  alias Eden.Repo

  ## Channels
  channel "characters:*", Eden.CharacterChannel
  channel "api:*", Eden.ApiChannel

  ## Transports
  transport :websocket, Phoenix.Transports.WebSocket
  transport :longpoll, Phoenix.Transports.LongPoll

  def connect(%{"token" => token}, socket) do
    case Token.verify(socket, "player_id", token, max_age: 1209600) do
      {:ok, player_id} ->
        {:ok, assign(socket, :player, Repo.get!(Player, player_id))}
      {:error, _} ->
        :erroR
    end
  end

  # Socket id's are topics that allow you to identify all sockets for a given player:
  #
  #     def id(socket), do: "player_socket:#{socket.assigns.player_id}"
  #
  # Would allow you to broadcast a "disconnect" event and terminate
  # all active sockets and channels for a given player:
  #
  #     Eden.Endpoint.broadcast("player_socket:" <> session.id, "disconnect", %{})
  #
  # Returning `nil` makes this socket anonymous.
  def id(socket) do
    "player_socket:#{socket.assigns.player.id}"
  end
end
