defmodule Eden.Scheduler do
  alias Eden.World
  use GenServer

  @default_options %{}

  # API
  def start_link do
  	GenServer.start_link(__MODULE__, nil, name: :scheduler)
  end

  def start(options \\ %{}) do
    GenServer.call(__MODULE__, {:start, options})
  end

  def stop do
    GenServer.call(__MODULE__, :stop)
  end

  # Callbacks
  def init(_input) do
  	{:ok, nil}
  end

  def handle_call({:start, options}, _from, world) do
    # The world may or may not have been initialized before
    # first search for existing worlds based on name passed in the options
    # if one exists, grab this data and execute the start function on it with the passed in options
    # if one doesn't exist, create a new world, initialize it, and start it with the options

    # every interation of the world should return any messages that need to be sent
    case World.start(world, options) do
      {:ok, world} ->
        {:reply, :ok, world}
      {:error, world} ->
        {:reply, :error, world}
    end
  end

  def handle_call(:stop, _from, world) do
    case World.stop(world) do
      {:ok, world} ->
        {:reply, :ok, world}
      {:error, world} ->
        {:reply, :error, world}
    end
  end

  #
  # Private Functions
  #
end
