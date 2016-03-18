defmodule Eden.Api do
  @moduledoc """
  Maps api operation strings with the correct callback module.
  """

  alias Eden.Session
  import Eden.Api.Context
  import Phoenix.Socket, only: [assign: 3]
  require Logger

  def join("api:v1", %{token: token}, context) do
    socket = get_socket(context)
    case validate_token(token) do
      {:ok, session_token} ->
        case Session.initialize(session_token) do
          {:ok, session} ->
            context
            |> set_socket(assign(socket, :session, session))
            |> set_result_code(:ok)
          true ->
            context
            |> set_result_code(:error)
            |> set_result_message(%{message: "Unable to initialize session."})
        end
      {:error, :invalid} ->
        context
        |> set_result_code(:error)
        |> set_result_message(%{message: "Invalid session token."})
    end
  end

  def handle_in("ping", _payload, context) do
    context
    |> set_result_code(:ok)
    |> set_result_message("pong")
  end

  def terminate(_reason, context) do
    socket = get_socket(context)
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

