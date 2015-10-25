defmodule Eden.CharacterChannel do
  use Eden.Web, :channel

  def join("characters:" <> name, payload, socket) do
    # fetch character
    # if exists, does player have permission
    #   if player has permission, reply with whatever text should be shown to players
    #   when logging into a character. In advanced cases this might include a backlog
    #   of missed messages, event alerts, and so on.
    # if doesn't exist error

    #case Repo.get_by!(Character, name: name) do
    #  nil ->
    #    case Repo.get_by!(Player, email: search) do
    #      nil ->
    #        conn
    #        |> send_resp(:not_found, "")
    #      result ->
    #        player = result
    #    end
    #  result ->
    #    player = result
    #end


    {:ok, "Welcome, #{name}!", socket}
  end

  # Channels can be used in a request/response fashion
  # by sending replies to requests from the client
  def handle_in("ping", payload, socket) do
    {:reply, {:ok, payload}, socket}
  end

  # It is also common to receive messages from the client and
  # broadcast to everyone in the current topic (characters:lobby).
  def handle_in("shout", payload, socket) do
    broadcast socket, "shout", payload
    {:noreply, socket}
  end

  # This is invoked every time a notification is being broadcast
  # to the client. The default implementation is just to push it
  # downstream but one could filter or change the event.
  def handle_out(event, payload, socket) do
    push socket, event, payload
    {:noreply, socket}
  end

  # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end
end
