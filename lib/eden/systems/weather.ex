defmodule Eden.System.Weather do
  @moduledoc """
  Changes the weather as time passes to provide a dynamic weather system at
  arbitrary granularity.
  """
  alias Eden.Entity
  use GenServer

  @run_interval 500 # ms
  @weather_regions_component :weather_region

  # API
  def start_link(env) do
    GenServer.start_link(__MODULE__, env, name: __MODULE__)
  end

  # Callbacks
  def init(env) do
    # weather_regions = Entity.transaction(fn ->
    #   Entity.list_with_components(@weather_regions_component)
    # end)
    # {:ok, %{env: env, weather_regions: weather_regions}, 0}

    {:ok, true}
  end

  @doc """
  Acts as the main loop of the server. All handle_* callbacks must return a
  timeout with each reply in order to make this work.
  """
  def handle_into(:timeout, state) do
    {:noreply, state, @run_interval}
  end

  #
  # Private Functions
  #
end