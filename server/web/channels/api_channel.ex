defmodule Eden.ApiChannel do
  alias Eden.Api.Router
  alias Eden.Player
  alias Eden.Session
  import Eden.Api.Context
  require Logger
  use Eden.Web, :channel

  def join(operation, payload, socket) do
    try do
      context = Router.route(:join, operation, payload, new(socket)) # New context
      {get_result_code(context), %{"data" => get_result_data(context)}, get_socket(context)}
    rescue
      FunctionClauseError ->
        Logger.warn "Client attempted invalid channel join: #{operation}"
        {:error, %{"data" => "Invalid operation"}, socket}
    end
  end 

  def handle_in(operation, payload, socket) do
    try do
      context = Router.route(:handle_in, operation, payload, new(socket)) # New context
      {:reply, {get_result_code(context), %{"data" => get_result_data(context)}}, get_socket(context)}
    rescue
      FunctionClauseError ->
        Logger.warn "Client made request for invalid operation: #{operation}"
        {:reply, {:error, %{"data" => "Invalid operation"}}, socket}
    end
  end

  def handle_out(operation, payload, socket) do
    try do
      context = Router.route(:handle_out, operation, payload, new(socket)) # New context
      if get_result_code(context) == :ok do
        push socket, operation, %{"data" => get_result_data(context)}
      end
      {:noreply, get_socket(context)}
    rescue
      FunctionClauseError ->
        push socket, operation, %{"data" => payload}
        {:noreply, socket}
    end
  end

  def terminate(_reason, socket) do
    Session.update(socket.assigns.session)
  end
end
