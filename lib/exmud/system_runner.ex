defmodule Exmud.SystemRunner do
  @moduledoc false
  alias Ecto.Changeset
  alias Exmud.Registry
  alias Exmud.Repo
  alias Exmud.Schema.System, as: S
  import Ecto.Query
  import Exmud.Utils
  use GenServer
  
  #
  # Worker Callback
  #
  
  
  def start_link(name, callback_module, args) do
    GenServer.start_link(__MODULE__, {name, callback_module, args})
  end


  #
  # GenServer Callbacks
  #


  def init({name, callback_module, args}) do
    if Registry.register_key(name, self()) == :ok do
      Repo.one(
        from system in S,
        where: system.key == ^name,
        select: system
      )
      |> case do
        nil ->
          initial_state = callback_module.initialize(args)
          serialized_state = :erlang.term_to_binary(initial_state)
          serialized_callback = :erlang.term_to_binary(callback_module)
          S.changeset(%S{}, %{key: name, state: serialized_state, callback: serialized_callback})
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
            
          serialized_callback = :erlang.term_to_binary(callback_module)
          {state, timeout} = callback_module.start(args, initial_state) |> normalize_result()
          maybe_queue_run(timeout)
          system = Changeset.put_change(system, :callback, serialized_callback)
          {:ok, %{callback_module: callback_module, state: state, system: system}}
      end
    else
      {:stop, {:shutdown, :already_started}}
    end
  end

  def handle_call(:state, _from, %{state: state} = data) do
    {:reply, state, data}
  end

  def handle_call({:stop, args}, _from, %{callback_module: callback_module, system: system, state: state} = _data) do
    new_state = callback_module.stop(args, state)
    :ok = Registry.unregister_key(Changeset.get_field(system, :key))
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

  def handle_call({:message, message}, _from,  %{callback_module: callback_module, state: state} = data) do
    case callback_module.handle_message(message, state) do
      {response, new_state, timeout} ->
        maybe_queue_run(timeout)
        {:reply, response, Map.put(data, :state, new_state)}
      {response, new_state} ->
        {:reply, response, Map.put(data, :state, new_state)}
    end
  end

  def handle_cast({:message, message}, %{callback_module: callback_module, state: state} = data) do
    {_response, new_state} = callback_module.handle_message(message, state)
    
    {:noreply, Map.put(data, :state, new_state)}
  end

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