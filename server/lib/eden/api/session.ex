defmodule Eden.Api.Session do
  @moduledoc """
  Maps api operation strings with the correct callback module.
  """

  alias Eden.Session
  import Eden.Api.Context
  use Eden.Web, :channel

  def handle_in("session:authenticate", %{login: login, password: password}, context) do
    socket = get_socket(context)
    case Session.authenticate(socket.assigns.session, login, password) do
      {:ok, session} ->
        context
        |> set_socket(assign(socket, :session, session))
        |> set_result_code(:ok)
      _ ->
        context
        |> set_result_code(:error)
        |> set_result_message("Unable to authenticate.")
    end
  end

  def handle_in("session:is_authenticated", _, context) do
    socket = get_socket(context)
    authenticated = Session.is_authenticated?(socket.assigns.session)
    context
    |> set_result_code(:ok)
    |> set_result_message(authenticated)
  end

  def handle_in("session:repudiate", _, context) do
    socket = get_socket(context)
    case Session.repudiate(socket.assigns.session) do
      {:ok, session} ->
        context
        |> set_socket(assign(socket, :session, session))
        |> set_result_code(:ok)
      _ ->
        context
        |> set_result_code(:error)
        |> set_result_message("Unable to repudiate.")
    end
  end
end

