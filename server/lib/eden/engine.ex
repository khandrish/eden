defmodule Eden.Engine do
  defmodule State do
    defstruct engine_state: :cold, state_entity: nil
  end

  alias Eden.EngineFsm, as: EF
  alias Eden.EntityManager, as: EM
  use GenServer

  # API
  def start_link do
  	GenServer.start_link(__MODULE__, nil, name: :engine)
  end

  def start do
    GenServer.call(__MODULE__, :start)
  end

  def stop do
    GenServer.call(__MODULE__, :stop)
  end

  # Callbacks
  def init(_input) do
    EM.create_caches
  	{:ok, EF.new}
  end

  def handle_call(:start, _from, engine) do
    case engine.start do
      {:ok, engine} ->
        {:reply, :ok, engine}
      {:error, engine} ->
        {:reply, :error, engine}
    end
  end

  def handle_call(:stop, _from, engine) do
    case engine.stop do
      {:ok, engine} ->
        {:reply, :ok, engine}
      {:error, engine} ->
        {:reply, :error, engine}
    end
  end

  #
  # Private Functions
  #
end
