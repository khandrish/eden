defmodule Eden.System.Scheduler do
  @moduledoc """
  Manages the lifecycle of scheduled tasks. Scheduled tasks can come in the
  form of one time actions scheduled to be executed at some point in time
  or periodic tasks which must be run multiple times.
  """

  use GenServer

  @scheduler_component :scheduler

  # API
  def start_link(env) do
    GenServer.start_link(__MODULE__, env, name: __MODULE__)
  end

  # Callbacks
  def init(env) do
    {:ok, %{env: env}}
  end

  @doc """
  Acts as the main loop of the server. All handle_* callbacks must return a
  timeout with each reply in order to make this work.
  """
  def handle_into(:timeout, state) do
    {:noreply, state, 50}
  end

  #
  # Private Functions
  #
end