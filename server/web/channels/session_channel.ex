defmodule Eden.SessionChannel do
  alias Eden.Session
  use Eden.Web, :channel

  def join("session:" <> sid, %{token: token}, socket) do
    result =
      with {:ok, session_id} <- validate_token(token),
           true <- sid == session_id,
        do: Session.initialize(session_id)

    case result do
      {:ok, session} ->
        {:ok, assign(socket, :session, session)}
      {:error, message} ->
        {:error, %{message: message}}
      false ->
        {:error, %{message: "Invalid token."}}
      true ->
        {:error, %{message: "Something went wrong. Spooky."}}
    end
  end

  def handle_in("ping", _, socket) do
    {:reply, {:ok, %{data: "pong"}}, socket}
  end

  def handle_out(event, payload, socket) do
    push socket, event, %{data: payload}
    {:noreply, socket}
  end

  defp authorized?(token) do
    with {:ok, session_token} <- validate_token(token),
         {:ok, session} <- Session.initialize(session_token),
      do: {:ok, assign(socket, :session, session)}
  end

  defp validate_token(token) do
    session_ttl = Application.get_env(:eden, :session_ttl)
    Phoenix.Token.verify(Eden.Endpoint, "session_token", token, max_age: session_ttl)
  end
end
