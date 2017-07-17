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
  # Worker Callback
  #


  @doc false
  def start_link(key, callback_module, args, options) do
    case GenServer.start_link(__MODULE__, {key, callback_module, args, options}, name: via(@system_registry, key)) do
      {:error, {:already_started, _pid}} -> {:error, :already_started}
      result -> result
    end
  end


  #
  # GenServer Callbacks
  #


  @doc false
  def init({key, callback_module, args, options}) do
    system =
      from(system in System, where: system.key == ^key)
      |> Repo.one()

    case do_initialization(key, callback_module, system, args, options) do
      {:ok, initial_state, system} ->
        callback_module.start(args, initial_state)
        |> normalize_noreply_result(options)
        |> case do
          {:ok, new_state, timeout} ->
            maybe_queue_run(timeout)
            Logger.info("System started with key `#{key}` and callback module `#{callback_module}`.")
            {:ok, %{callback_module: callback_module, options: options, state: new_state, system: system}}
          {:error, error} ->
            Logger.error("Attempt to start system with key `#{key}` and callback module `#{callback_module}` failed with error `#{error}`.")
            {:stop, error}
        end
      {:error, reason} ->
        {:stop, reason}
    end
  end

  @doc false
  def handle_call(:state, _from, %{state: state} = data) do
    {:reply, state, data}
  end

  @doc false
  def handle_call({:stop, args}, _from, %{callback_module: callback_module, system: system, state: state} = _data) do
    case callback_module.stop(args, state) do
      {:ok, new_state} ->
        system
        |> System.update(%{state: serialize(new_state)})
        |> Repo.update()

        {:stop, :normal, {:ok, true}, system}
      {:error, error, new_state} ->
        {:stop, :normal, {:error, error}, new_state}
    end
  end

  @doc false
  def handle_call({:message, message}, _from,  %{callback_module: callback_module, options: options, state: state} = data) do
    callback_module.handle_message(message, state)
    |> normalize_reply_result(options)
    |> case do
      {:ok, response, new_state, timeout} ->
        maybe_queue_run(timeout)
        {:reply, {:ok, response}, Map.put(data, :state, new_state)}
      {:error, error, new_state} ->
        {:reply, {:error, error}, Map.put(data, :state, new_state)}
      {:stop, reason, new_state} ->
        {:stop, reason, {:ok, :stopping}, Map.put(data, :state, new_state)}
      {:stop, reason, response, new_state} ->
        {:stop, reason, response, Map.put(data, :state, new_state)}
    end
  end

  @doc false
  def handle_cast({:message, message}, %{callback_module: callback_module, state: state} = data) do
    {:ok, _response, new_state} = callback_module.handle_message(message, state)

    {:noreply, Map.put(data, :state, new_state)}
  end

  @doc false
  def handle_info(:run, %{callback_module: callback_module, options: options, state: state, system: system} = data) do
    state
    |> callback_module.run()
    |> normalize_noreply_result(options)
    |> case do
      {:ok, new_state, timeout} ->
        maybe_queue_run(timeout)
        system = update_and_maybe_persist(system, new_state)
        {:noreply, %{data | :state => new_state, :system => system}}
      {:error, error, new_state} ->
        system = update_and_maybe_persist(system, new_state)
        {:stop, {:callback_error, error}, system.state}
    end
  end


  #
  # Private Functions
  #

  defp do_initialization(key, callback_module, nil, args, options) do
    system = %System{}
    args
    |> callback_module.initialize()
    |> normalize_noreply_result(options)
    |> case do
      {:error, _reason} = error ->
        error
      ok_result ->
        state = elem(ok_result, 1)
        {:ok, system} =
          System.new(system, %{key: key, options: serialize(options), state: serialize(state)})
          |> Repo.insert()

        {:ok, state, system}
    end
  end

  defp do_initialization(_key, callback_module, system, args, options) do
    initial_state = deserialize(system.state)
    callback_module.initialize(args, initial_state)
    |> normalize_noreply_result(options)
    |> case do
      {:error, _reason} = error ->
        error
      ok_result ->
        state = elem(ok_result, 1)

        {:ok, system} =
          System.update(system, %{options: serialize(options), state: serialize(state)})
          |> Repo.update()

        {:ok, deserialize(system.state), system}
    end
  end


  defp normalize_noreply_result({:ok, _, _} = result, _options), do: result

  defp normalize_noreply_result({:ok, _} = result, options) do
    Tuple.append(result, Keyword.get(options, :run_interval))
  end

  defp normalize_noreply_result(error, _options), do: error


  defp normalize_reply_result({:ok, _, _, _} = result, _options), do: result

  defp normalize_reply_result({:ok, _, _} = result, options) do
    Tuple.append(result, Keyword.get(options, :run_interval))
  end

  defp normalize_reply_result(error, _options), do: error

  defp maybe_queue_run(timeout) do
    if timeout !== :never do
      Process.send_after(self(), :run, timeout)
    end
  end

  defp update_and_maybe_persist(system, new_state) do
    # TODO: Allow for different update strategies, such as each time, every X runs, min/max interval in seconds.
    Repo.update(System.update(system, serialize(new_state)))
  end
end