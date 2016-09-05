defmodule Eden.ServiceManager do
  use GenServer

  # API
  def start_link(services) do
  	GenServer.start_link(__MODULE__, services, name: __MODULE__)
  end

  def deregister_services(services) when is_list(services) do
    GenServer.call(__MODULE__, {:deregister, services})
  end

  def deregister_services(service) do
    deregister_services([service])
  end

  def register_services(services) when is_list(services) do
    GenServer.call(__MODULE__, {:register, services})
  end

  def register_services(service) do
    register_services([service])
  end

  def start_all_services do
    GenServer.call(__MODULE__, {:start, :all})
  end

  def stop_all_services do
    GenServer.call(__MODULE__, {:start, :all})
  end

  def start_services(services) when is_list(services) do
    GenServer.call(__MODULE__, {:start, services})
  end

  def start_services(service) do
    start_services([service])
  end

  def stop_services(services) when is_list(services) do
    GenServer.call(__MODULE__, {:stop, services})
  end

  def stop_services(service) do
    stop_services([service])
  end

  # Callbacks
  def init(services) do
  	{:ok, MapSet.new(services)}
  end

  def handle_call({:start, :all}, _from, services) do
    :ok = start_services(MapSet.to_list(services))
    {:reply, :ok, services}
  end

  def handle_call({:start, services_to_start}, _from, services) do
    case MapSet.subset(MapSet.new(services_to_start), services) do
      true ->
        start_services(services_to_start)
        {:reply, :ok, services}
      false ->
        {:reply, {:error, :not_all_services_registered}, services}
    end
  end

  def handle_call({:stop, :all}, _from, services) do
    :ok = start_services(MapSet.to_list(services))
    {:reply, :ok, services}
  end

  def handle_call({:stop, services_to_stop}, _from, services) do
    case MapSet.subset(MapSet.new(services_to_stop), services) do
      true ->
        stop_services(services_to_stop)
        {:reply, :ok, services}
      false ->
        {:reply, {:error, :not_all_services_registered}, services}
    end
  end

  #
  # Private Functions
  #

  defp start_services(services) do
    Enum.each(services, &(&1.start()))
  end

  defp stop_services(services) do
    Enum.each(services, &(&1.stop()))
  end
end
