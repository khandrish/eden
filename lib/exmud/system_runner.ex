defmodule Exmud.SystemRunner do
  @moduledoc false
  alias Exmud.Db
  alias Exmud.Registry
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
    if Registry.register_name(name) == true do
      data =
        Db.transaction(fn ->
          case Db.find_with_all(name) do
            [entity] ->
              {entity, Db.read(entity, name, :state), 0}
            [] -> nil
          end
        end)
      
      # While it would be appropriate to put this logic in the case statement above, the initialize call must
      # be made outside of a transaction, forcing this ugly separation.
      {entity, initial_state, timeout} =
        case data do
          nil ->
            {initial_state, timeout} = callback_module.initialize(args) |>  normalize_result()
            entity = 
              Db.transaction(fn ->
                Db.create()
                |> Db.write(name, :state, initial_state)
              end)
            {entity, initial_state, timeout}
          data -> data
        end
      
      if timeout !== :never do
        Process.send_after(self(), :run, timeout) 
      end
    
      {:ok, %{callback_module: callback_module, entity: entity, name: name, state: initial_state}}
    else
      {:stop, {:shutdown, :already_started}}
    end
  end

  def handle_call(:state, _from, %{state: state} = data) do
    {:reply, state, data}
  end

  def handle_call({:stop, args}, _from, %{callback_module: callback_module, entity: entity, name: name, state: state} = data) do
    new_state = callback_module.stop(args, state)
    :ok = Registry.unregister_name(name)
    
    Db.transaction(fn ->
      Db.write(entity, name, :state, new_state)
    end)
    
    {:stop, :normal, :ok, Map.put(data, :state, new_state)}
  end

  def handle_call({:message, message}, _from,  %{callback_module: callback_module, state: state} = data) do
    {response, new_state} = callback_module.handle_message(message, state)
    
    {:reply, response, Map.put(data, :state, new_state)}
  end

  def handle_cast({:message, message}, %{callback_module: callback_module, state: state} = data) do
    {_response, new_state} = callback_module.handle_message(message, state)
    
    {:noreply, Map.put(data, :state, new_state)}
  end

  def handle_info(:run, %{callback_module: callback_module, state: state} = data) do
    {new_state, timeout} = callback_module.run(state) |> normalize_result()
    
    if timeout !== :never do
      Process.send_after(self(), :run, timeout) 
    end
    
    {:noreply, Map.put(data, :state, new_state)}
  end
  
  
  #
  # Private Functions
  #
  
  
  defp normalize_result(result) when is_tuple(result), do: result
  defp normalize_result(state), do: {state, cfg(:default_system_run_timeout)}
end