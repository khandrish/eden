defmodule Exmud.Engine.SystemRunner do
  @moduledoc false

  alias Exmud.Engine.Repo
  alias Exmud.Engine.Schema.System
  import Ecto.Query
  import Exmud.Common.Utils
  import Exmud.Engine.Utils
  require Logger
  use GenServer

  @system_registry system_registry()


  #
  # Worker callback used by the supervisor when starting a new system runner.
  #


  @doc false
  def start_link(key, callback_module, args) do
    case GenServer.start_link(__MODULE__, {key, callback_module, args}, name: via(@system_registry, key)) do
      {:error, {:already_started, _pid}} -> {:error, :already_started}
      result -> result
    end
  end


  #
  # Initialization of the GenServer and the system it is managing.
  #


  @doc false
  def init({key, callback_module, initialization_args}) do
    system =
      key
      |> load_system()
      |> normalize_system(callback_module)

    initialization_result = system.callback_module.initialize(initialization_args, system.state)

    if elem(initialization_result, 0) == :ok do
      Logger.info("System started with key `#{key}` and callback module `#{callback_module}`.")

      state = elem(initialization_result, 1)
      {:ok, system} = Repo.insert_or_update(System.new(system, %{key: key, state: serialize(state)}))
      system = %{system | :state => deserialize(system.state)}

      state = %{callback_module: callback_module, state: state, system: system}

      case initialization_result do
        {_, _} ->
          {:ok, state}
        {_, _, time} ->
          Process.send_after(self(), :auto_run, time)

          {:ok, state}
      end
    else
      {:stop, elem(initialization_result, 1)}
    end
  end

  @doc false
  def handle_call(:manual_run, _from, data) do
    doo_run_run(data)
  end


  @doc false
  def handle_call({:message, message}, _from, data) do
    data.callback_module.handle_message(message, data.state)
    |> case do
      {:ok, response, new_state} ->
        {:reply, {:ok, response}, Map.put(data, :state, new_state)}
      {:ok, response, new_state, time} ->
        Process.send_after(self(), :auto_run, time)

        {:reply, {:ok, response}, Map.put(data, :state, new_state)}
      {:error, error, new_state} ->
        {:reply, {:error, error}, Map.put(data, :state, new_state)}
      {:stop, response, new_state} ->
        {:stop, :normal, {:ok, response}, Map.put(data, :state, new_state)}
    end
  end

  @doc false
  def handle_call(:state, _from, %{state: state} = data) do
    {:reply, {:ok, state}, data}
  end

  @doc false
  def handle_call({:stop, args}, _from, data) do
    case data.callback_module.stop(args, data.state) do
      {:ok, reply, new_state} ->
        data.system
        |> System.update(%{state: serialize(new_state)})
        |> Repo.update()

        {:stop, :normal, {:ok, reply}, new_state}
      {:error, error, new_state} ->
        {:stop, :normal, {:error, error}, new_state}
    end
  end

  @doc false
  def handle_cast({:message, message}, data) do
    {:ok, _response, new_state} = data.callback_module.handle_message(message, data.state)

    {:noreply, Map.put(data, :state, new_state)}
  end

  @doc false
  def handle_info(:auto_run, data) do
    case doo_run_run(data) do
      {:reply, _, new_state} ->
        {:noreply, new_state}
      {:stop, reason, _reply, state} ->
        {:stop, reason, state}
    end
  end


  #
  # Private Functions
  #

  defp doo_run_run(data) do
    data.state
    |> data.callback_module.run()
    |> case do
      {:ok, reply, new_state} ->
        system = update_and_persist(data.system, new_state)
        {:reply, {:ok, reply}, %{data | :state => new_state, :system => system}}
      {:ok, reply, new_state, time} ->
        Process.send_after(self(), :auto_run, time)

        system = update_and_persist(data.system, new_state)
        {:reply, {:ok, reply}, %{data | :state => new_state, :system => system}}
      {:error, reply, new_state} ->
        system = update_and_persist(data.system, new_state)
        {:reply, {:error, reply}, %{data | :state => new_state, :system => system}}
      {:stop, reply, new_state} ->
        system = update_and_persist(data.system, new_state)
        {:stop, :normal, {:ok, reply}, %{data | :state => new_state, :system => system}}
    end
  end

  defp load_system(key) do
    case Repo.one(from(system in System, where: system.key == ^key)) do
      nil ->
        %System{key: key, state: serialize(nil)}
      system ->
        system
    end
  end

  defp normalize_system(system, callback_module) do
    %{system | callback_module: callback_module, state: deserialize(system.state)}
  end

  defp update_and_persist(system, new_state) do
    {:ok, system} = Repo.update(System.update(system, %{state: serialize(new_state)}))
    %{system | :state => deserialize(system.state)}
  end
end