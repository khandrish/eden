defmodule Eden.Api.Router do
  @moduledoc """
  Maps api operation strings with the correct callback module.
  """

  @routing_table %{
    "api" => Eden.Api,
    "session" => Eden.Session
  }

  def route(method, "api" <> _ = operation, params, context) do
    apply(Eden.Api, method, [operation, params, context])
  end

  def route(method, "ping" = operation, params, context) do
    apply(Eden.Api, method, [operation, params, context])
  end

  def route(method, "session" <> _ = operation, params, context) do
    apply(Eden.Api.Session, method, [operation, params, context])
  end
end