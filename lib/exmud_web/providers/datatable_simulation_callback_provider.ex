defmodule ExmudWeb.DatatableMudCallbackProvider do
  import Phoenix.HTML
  use ExmudWeb.DatatableLiveProvider

  @impl ExmudWeb.DatatableLiveProvider
  def load(state) do
    Exmud.Engine.list_mud_callbacks(state.args.mud_id)
  end

  @impl ExmudWeb.DatatableLiveProvider
  def render_row_column([:default_config], value, _state) do
    ~E"""
    <pre><%= Poison.encode!(value, pretty: true) %></pre>
    """
  end

  @impl ExmudWeb.DatatableLiveProvider
  def render_row_column([:callback, :docs], value, _state) do
    ~E"""
    <pre><%= value %></pre>
    """
  end

  @impl ExmudWeb.DatatableLiveProvider
  def render_row_column(_path, value, _state) do
    value
  end
end
