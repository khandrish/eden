defmodule Exmud.Engine.System do
  @moduledoc """
  Systems form the backbone of the Engine, driving time and message based actions within the game world.

  Examples include weather effects, triggering invasions, regular spawning of critters, the day/night cycle, and so on.
  Unlike Scripts, which can be added as many times to as many different Objects as you want, only one of each registered
  System may run at a time.

  Systems can transition between a set schedule, dynamic schedule, and purely message based seamlessly at runtime simply
  by modifying the value returned from the `run/1` callback. Note that while it is possible to run only in response to
  being explicitly called, short of not implementing the `handle_message/2` callback it is not possible for the Engine
  to enforce a schedule only mode. Only you can prevent messages by not calling the System directly in your code.
  """


  #
  # API
  #


  alias Exmud.Engine.Cache
  alias Exmud.Engine.Repo
  alias Exmud.Engine.Schema.System
  import Ecto.Query
  import Exmud.Common.Utils
  require Logger

  @system_registry :exmud_engine_system_registry

  @doc """
  Call a running system with a message.
  """
  def call(key, message) do
    send_message(:call, key, message)
  end

  @doc """
  Cast a message to a running system.
  """
  def cast(key, message) do
    send_message(:cast, key, message)

    {:ok, true}
  end

  @doc """
  Get the state of a system.
  """
  def get_state(key) do
    try do
      GenServer.call(via(@system_registry, key), :state, :infinity)
    catch
      :exit, {:noproc, _} ->
        system_query(key)
        |> Repo.one()
        |> case do
          nil -> {:error, :no_such_system}
          system ->
            {:ok, deserialize(system.state)}
        end
    end
  end

  @doc """
  Purge system data from the database.
  """
  def purge(key) do
    system_query(key)
    |> Repo.one()
    |> case do
      nil -> {:error, :no_such_system}
      system ->
        {:ok, _} = Repo.delete(system)
        {:ok, deserialize(system.state)}
    end
  end

  @doc """
  Trigger a system to run immediately. If a system is running while this call is made the system will run again
  as soon as it can and the result returned.
  """
  def run(key) do
    try do
      GenServer.call(via(@system_registry, key), :start_running, :infinity)
    catch
      :exit, {:noproc, _} -> {:error, :system_not_running}
    end
  end

  @doc """
  Check to see if a system is running.
  """
  def running?(key) do
    result = Registry.lookup(@system_registry, key)
    {:ok, result != []}
  end

  @doc """
  Start a system.
  """
  def start(key, args \\ nil) do
    with  {:ok, _} <- Supervisor.start_child(Exmud.Engine.SystemRunnerSupervisor, [key, args]),

      do: {:ok, :started}
  end

  @doc """
  Stops a system if it is started.
  """
  def stop(key, args \\ %{}) do
    try do
      GenServer.call(via(@system_registry, key), {:stop, args}, :infinity)
    catch
      :exit, {:noproc, _} -> {:error, :system_not_running}
    end
  end


  #
  # Manipulation of Systems in the Engine.
  #


  @cache :system_cache

  def list_registered() do
    Logger.info("Listing all registered Systems")
    Cache.list(@cache)
  end

  def lookup(key) do
    case Cache.get(@cache, key) do
      {:error, _} ->
        Logger.error("Lookup failed for System registered with key `#{key}`")
        {:error, :no_such_system}
      result ->
        Logger.info("Lookup succeeded for System registered with key `#{key}`")
        result
    end
  end

  def register(key, callback_module) do
    Logger.info("Registering System with key `#{key}` and module `#{inspect(callback_module)}`")
    Cache.set(@cache, key, callback_module)
  end

  def registered?(key) do
    Logger.info("Checking registration of System with key `#{key}`")
    Cache.exists?(@cache, key)
  end

  def unregister(key) do
    Logger.info("Unregistering System with key `#{key}`")
    Cache.delete(@cache, key)
  end


  #
  # Internal Functions
  #


  defp send_message(method, key, message) do
    try do
      apply(GenServer, method, [via(@system_registry, key), {:message, message}])
    catch
      :exit, {:noproc, _} -> {:error, :system_not_running}
    end
  end

  defp system_query(key) do
    from system in System,
      where: system.key == ^key
  end
end