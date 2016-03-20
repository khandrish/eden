defmodule Eden.SessionChannel do
  use Eden.Web, :channel

  def join("session:" <> id, %{token: token}, socket) do
    result =
      with true <- id == token,
           {:ok, session_token} <- validate_token(token),
        do: Session.initialize(session_token)

    case result do
      {:ok, session} ->
        {:ok, assign(socket, :session, session)}
      {:error, message} ->
        {:error, %{message: message}}
      false ->
        {:error, %{message: "Invalid token"}}
      true ->
        {:error, %{message: "Something went wrong. Spooky."}}
    end
  end

  # Channels can be used in a request/response fashion
  # by sending replies to requests from the client
  def handle_in("ping", _, socket) do
    {:reply, {:ok, "pong"}, socket}
  end

  # It is also common to receive messages from the client and
  # broadcast to everyone in the current topic (session:lobby).
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
  defp authorized?(token) do
    with {:ok, session_token} <- validate_token(token),
         {:ok, session} <- Session.initialize(session_token),
      do: {:ok, assign(socket, :session, session)}
  end

  defp validate_token(token) do
    session_ttl = Application.get_env(:eden, :session_ttl)
    Phoenix.Token.verify(Eden.Endpoint, "session token", token, max_age: session_ttl)
  end
end
