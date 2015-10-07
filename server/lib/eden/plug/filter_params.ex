defmodule Eden.Plug.FilterParams do
  @moduledoc """
    Authenticated plug can be used ensure an action can only be triggered by
    players that are authenticated.
  """
  import Plug.Conn

  def init(allowed_params) do
    allowed_params
  end

  def call(%Plug.Conn{params: params} = conn, allowed_params) do
    %{conn | params: Map.take(params, allowed_params)}
  end
end