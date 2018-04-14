defmodule Exmud.Game.MasterControlProgram do
  alias Exmud.Engine.Cache
  alias Exmud.Engine.Callback
  alias Exmud.Engine.CommandSet
  alias Exmud.Engine.Component
  alias Exmud.Engine.Script
  alias Exmud.Engine.System
  import Exmud.Game.Utils
  require Logger
  use GenServer

  defmodule State do
    defstruct running: false
  end


  #
  # Worker callback used by the supervisor when starting the MCP.
  #


  @doc false
  def start_link(), do:  GenServer.start_link(__MODULE__, nil, name: __MODULE__)


  #
  # Master Control Program API
  #


  def restart, do: with {:ok, _} <- stop(), do: start()
  def running?, do: is_running?()
  def start, do: GenServer.call(__MODULE__, :start, :infinity)
  def stop, do: GenServer.call(__MODULE__, :stop, :infinity)


  #
  # GenServer callbacks
  #


  @doc false
  def init(_), do: do_init()

  @doc false
  def handle_call(:start, _from, state), do: do_start(state)

  @doc false
  def handle_call(:stop, _from, state), do: do_stop(state)


  #
  # Initializing MCP consists of registering all configured callback modules
  #


  @things_to_register [:callbacks, :command_sets, :components, :scripts, :systems]
  @thing_module_map %{callbacks: Callback,
                      command_sets: CommandSet,
                      components: Component,
                      scripts: Script,
                      systems: System}

  defp do_init do
    :ok = register_all_the_things(@things_to_register)

    {:ok, %State{}}
  end

  defp register_all_the_things([]), do: :ok

  defp register_all_the_things([thing | things]) do
    Logger.info("Registering `#{thing}`")

    Enum.each(game_cfg(thing), fn({key, callback}) ->
      Logger.info("Registering `#{callback}`")

      # It's ok to assume success here. If the cache can't save a value there are bigger problems to worry about.
      # This is also during init, so a failure at this level will stop the process from starting and propagate that
      # error upwards.
      {:ok, _} = apply(Map.get(@thing_module_map, thing), :register, [key, callback])
    end)

    register_all_the_things(things)
  end


  #
  # Start the Engine. This means starting Systems and then all Scripts.
  #


  @things_to_start [:systems, :scripts]

  defp do_start(state) do
    if state.running do
      {:reply, {:error, :already_started}, state}
    else
      results = start_some_things(@things_to_start, %{})
      set_running(true)
      {:reply, {:ok, results}, %{state | running: true}}
    end
  end

  defp start_some_things([], results) do
    results
  end

  defp start_some_things([:systems | things], results) do
    system_results =
      System.list_registered()
      |> Enum.reduce(%{}, fn(key, map) ->
        Map.put(map, key, System.start(key))
      end)

    start_some_things(things, Map.put(results, :systems, system_results))
  end

  defp start_some_things([:scripts | things], results) do
    system_results =
      Script.list_registered()
      |> Enum.reduce(%{}, fn(key, map) ->
        Map.put(map, key, Script.start(key))
      end)

    start_some_things(things, Map.put(results, :scripts, system_results))
  end


  #
  # Stop the Engine. This means stopping all Scripts and Systems.
  #


  defp do_stop(state) do
    if state.running do
      results =
        System.list_registered()
        |> Enum.map(fn(key) ->
          {key, System.stop(key)}
        end)
        |> Enum.map(fn({:error, :system_not_running}) -> {:ok, :system_not_running};
                      (result) -> result
        end)

      set_running(false)
      {:reply, {:ok, results}, %{state | running: false}}
    else
      {:reply, {:error, :not_started}, state}
    end
     results =
        System.list_registered()
        |> Enum.map(fn(key) ->
          {key, System.stop(key)}
        end)
      {:reply, {:ok, results}, state}
  end


  #
  # State helpers
  #
  # Since checks against MCP state can come from multiple processes, the relevant pieces are kept in the Engine cache
  # and requsts for said state are rerouted to the cache in-process instead of sending a request to the single MCP
  # process
  #


  @mcp_category

  defp is_running? do
    {:ok, true} == Cache.get(@mcp_category, :running)
  end

  defp set_running(running) do
    Cache.set(@mcp_category, :running, running)
  end
end
