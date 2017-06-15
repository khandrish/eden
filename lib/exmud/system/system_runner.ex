defmodule Exmud.SystemRunner do
  @moduledoc false
  alias Ecto.Changeset
  alias Exmud.Cache
  alias Exmud.Repo
  alias Exmud.Schema.System, as: S
  import Ecto.Query
  import Exmud.Utils
  require Logger
  use GenServer

  @system_category "system"


  #
  # Worker Callback
  #


  @doc false
  def start_link(key, callback_module, args) do
    GenServer.start_link(__MODULE__, {key, callback_module, args})
  end


  #
  # GenServer Callbacks
  #


  @doc false
  @lint {Credo.Check.Refactor.PipeChainStart, false}
  def init({key, callback_module, args}) do
    if Cache.put(key, @system_category, self()) == :ok do
      Repo.one(
        from system in S,
        where: system.key == ^key,
        select: system
      )
      |> case do
        nil ->
          initial_state = callback_module.initialize(args)
          serialized_state = :erlang.term_to_binary(initial_state)
          S.changeset(%S{}, %{key: key, state: serialized_state})
          |> Repo.insert()
          |> case do
            {:ok, system} ->
              system = S.changeset(system)
              {state, timeout} = callback_module.start(args, initial_state) |> normalize_result()
              maybe_queue_run(timeout)
              {:ok, %{callback_module: callback_module, state: state, system: system}}
            {:error, changeset} ->
              {:stop, {:shutdown, {:error, changeset.errors}}}
          end
        system ->
          system = S.changeset(system)
          initial_state =
            system
            |> Changeset.get_field(:state)
            |> :erlang.binary_to_term()

          {state, timeout} = callback_module.start(args, initial_state) |> normalize_result()
          maybe_queue_run(timeout)
          Logger.info("System started with key `#{key}` and callback module `#{callback_module}`")
          {:ok, %{callback_module: callback_module, state: state, system: system}}
      end
    else
      {:stop, {:shutdown, :already_started}}
    end
  end

  @doc false
  def handle_call(:state, _from, %{state: state} = data) do
    {:reply, state, data}
  end

  @doc false
  @lint {Credo.Check.Refactor.PipeChainStart, false}
  def handle_call({:stop, args}, _from, %{callback_module: callback_module, system: system, state: state} = _data) do
    new_state = callback_module.stop(args, state)
    :ok = Cache.delete(Changeset.get_field(system, :key), @system_category)
    serialized_state = :erlang.term_to_binary(new_state)

    Changeset.put_change(system, :state, serialized_state)
    |> Repo.update()
    |> case do
      {:ok, system} ->
        {:stop, :normal, :ok, S.changeset(system)}
      {:error, changeset} ->
        {:stop, :normal, {:error, changeset.errors}, S.changeset(system)}
    end
  end

  @doc false
  def handle_call({:message, message}, _from,  %{callback_module: callback_module, state: state} = data) do
    case callback_module.handle_message(message, state) do
      {response, new_state, timeout} ->
        maybe_queue_run(timeout)
        {:reply, response, Map.put(data, :state, new_state)}
      {response, new_state} ->
        {:reply, response, Map.put(data, :state, new_state)}
    end
  end

  @doc false
  def handle_cast({:message, message}, %{callback_module: callback_module, state: state} = data) do
    {_response, new_state} = callback_module.handle_message(message, state)

    {:noreply, Map.put(data, :state, new_state)}
  end

  @doc false
  @lint {Credo.Check.Refactor.PipeChainStart, false}
  def handle_info(:run, %{callback_module: callback_module, state: state} = data) do
    {new_state, timeout} = callback_module.run(state) |> normalize_result()
    maybe_queue_run(timeout)

    {:noreply, Map.put(data, :state, new_state)}
  end


  #
  # Private Functions
  #


  defp normalize_result(result) when is_tuple(result), do: result
  defp normalize_result(state), do: {state, engine_cfg(:default_system_run_timeout)}

  defp maybe_queue_run(timeout) do
    if timeout !== :never do
      Process.send_after(self(), :run, timeout)
    end
  end
end
