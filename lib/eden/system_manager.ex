defmodule Eden.SystemManager do
  use GenServer

  # API
  def start_link(systems) do
  	GenServer.start_link(__MODULE__, systems, name: __MODULE__)
  end

  def deregister_systems(systems) when is_list(systems) do
    GenServer.call(__MODULE__, {:deregister, systems})
  end

  def deregister_systems(system) do
    deregister_systems([system])
  end

  def register_systems(systems) when is_list(systems) do
    GenServer.call(__MODULE__, {:register, systems})
  end

  def register_systems(system) do
    register_systems([system])
  end

  def start_all_systems do
    GenServer.call(__MODULE__, {:start, :all})
  end

  def stop_all_systems do
    GenServer.call(__MODULE__, {:start, :all})
  end

  def start_systems(systems) when is_list(systems) do
    GenServer.call(__MODULE__, {:start, systems})
  end

  def start_systems(system) do
    start_systems([system])
  end

  def stop_systems(systems) when is_list(systems) do
    GenServer.call(__MODULE__, {:stop, systems})
  end

  def stop_systems(system) do
    stop_systems([system])
  end

  # Callbacks
  def init(systems) do
  	{:ok, MapSet.new(systems)}
  end

  def handle_call({:start, :all}, _from, systems) do
    :ok = start_systems(MapSet.to_list(systems))
    {:reply, :ok, systems}
  end

  def handle_call({:start, systems_to_start}, _from, systems) do
    case MapSet.subset(MapSet.new(systems_to_start), systems) do
      true ->
        start_systems(systems_to_start)
        {:reply, :ok, systems}
      false ->
        {:reply, {:error, :not_all_systems_registered}, systems}
    end
  end

  def handle_call({:stop, :all}, _from, systems) do
    :ok = start_systems(MapSet.to_list(systems))
    {:reply, :ok, systems}
  end

  def handle_call({:stop, systems_to_stop}, _from, systems) do
    case MapSet.subset(MapSet.new(systems_to_stop), systems) do
      true ->
        stop_systems(systems_to_stop)
        {:reply, :ok, systems}
      false ->
        {:reply, {:error, :not_all_systems_registered}, systems}
    end
  end

  #
  # Private Functions
  #

  defp start_systems(systems) do
    Enum.each(systems, &(&1.start()))
  end

  defp stop_systems(systems) do
    Enum.each(systems, &(&1.stop()))
  end
end
