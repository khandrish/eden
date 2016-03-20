defmodule Eden.ApiChannel do
  alias Eden.Player
  alias Eden.Session
  use Eden.Web, :channel

  def join("api:v1", %{token: token}, socket) do
    case validate_token(token) do
      {:ok, session_token} ->
        case Session.initialize(session_token) do
          {:ok, session} ->
            {:ok, assign(socket, :session, session)}
          true ->
            {:error, %{message: "Unable to initialize session."}}
        end
      true ->
        {:error, %{message: "Invalid session token."}}
    end
  end

  def handle_in("ping", _payload, socket) do
    {:reply, :ok, socket}
  end

  def handle_in("session:authenticate", %{login: login, password: password}, socket) do
    case Session.authenticate(socket.assigns.session, login, password) do
      {:ok, session} ->
        socket = assign(socket, :session, session)
        {:reply, :ok, socket}
      _ ->
        {:reply, {:error, %{message: "Unable to authenticate."}}, socket}
    end
  end

  def handle_in("session:is_authenticated", _, socket) do
    authenticated = Session.is_authenticated?(socket.assigns.session)
    {:reply, {:ok, %{"result" => authenticated}}, socket}
  end

  def handle_in("session:repudiate", _, socket) do
    case Session.repudiate(socket.assigns.session) do
      {:ok, session} ->
        socket = assign(socket, :session, session)
        {:reply, :ok, socket}
      _ ->
        {:reply, {:error, %{message: "Unable to repudiate."}}, socket}
    end
  end

  def handle_out(event, payload, socket) do
    push socket, event, payload
    {:noreply, socket}
  end

  def terminate(_reason, socket) do
    Session.update(socket.assigns.session)
  end

  #
  # Private functions
  #

  defp validate_token(token) do
    session_ttl = Application.get_env(:eden, :session_ttl)
    Phoenix.Token.verify(Eden.Endpoint, "session token", token, max_age: session_ttl)
  end
end