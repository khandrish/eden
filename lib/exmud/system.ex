defmodule Exmud.System do
  @systemdoc """
  Systems form the backbone of the engine. They drive time and event based
  actions, covering everything from weather effects to triggering AI actions.
  
  Systems do not have to run on a set schedule and instead can only react to
  events, and vice versa 
  """

  alias Exmud.Db
  alias Exmud.Registry
  import Exmud.Utils
  use GenServer


  #
  # API
  #


  def call(systems, message) when is_list(systems) do
    systems
    |> Enum.map(fn(system) ->
      response = Registry.whereis_name(system)
      |> GenServer.call({:message, message})

      {system, response}
    end)
  end

  def call(system, message) do
    call([system], message)
    |> hd()
    |> elem(1)
  end

  def cast(systems, message) when is_list(systems) do
    systems
    |> Enum.map(fn(system) ->
      Registry.whereis_name(system)
      |> GenServer.cast({:message, message})
      system
    end)
  end

  def cast(system, message) do
    cast([system], message)
    |> hd()
  end

  def purge(names) when is_list(names) do
    Db.transaction(fn ->
      entities = Db.find_with_any(names)
      data = Db.read(entities, names)
      Db.delete(entities, names)
      data
    end)
    |> Enum.map(fn(entity) ->
      components = entity.components
      name = Map.keys(components) |> hd()
      state = Map.values(components) |> hd() |> Map.get(:state)
      {name, state}
    end)
  end

  def purge(system) do
    purge([system])
    |> hd()
    |> elem(1)
  end

  def running?(names) when is_list(names) do
    names
    |> Enum.map(fn(name) ->
      {name, Registry.whereis_name(name) != nil}
    end)
  end

  def running?(name) do
    running?([name])
    |> hd()
    |> elem(1)
  end

  def start(definitions, args \\ %{})
  def start(definitions, args) when is_list(definitions) do
    definitions
    |> Enum.map(fn(definition) ->
      {name, callback_module} =
        case definition do
          {_, _} = result -> result
          callback_module -> {callback_module, callback_module}
        end
        
      case Supervisor.start_child(Exmud.SystemSup, [name, callback_module, args]) do
        {:ok, _} -> name
        {:error, {_, reason}} -> {:error, reason}
      end
    end)
  end

  def start(definition, args) do
    start([definition], args)
    |> hd()
  end

  def state(names) when is_list(names) do
    names
    |> Enum.map(fn(name) ->
      state = 
        case Registry.whereis_name(name) do
          nil ->
            Db.transaction(fn ->
              case Db.find_with_all(name) do
                [] -> nil
                entities ->
                  entities
                  |> hd()
                  |> Db.read(name, :state)
              end
            end)
          pid ->
            GenServer.call(pid, :state)
        end
      
      {name, state}
    end)
  end

  def state(name) do
    state([name])
    |> hd()
    |> elem(1)
  end

  def stop(names, args \\ %{})
  def stop(names, args) when is_list(names) do
    names
    |> Enum.each(fn(name) ->
      Registry.whereis_name(name)
      |> GenServer.call({:stop, args})
    end)

    names
  end

  def stop(name, args), do: hd(stop([name], args))
  
  
  #
  # Worker Callback
  #
  
  
  @doc false
  def start_link(name, callback_module, args) do
    GenServer.start_link(__MODULE__, {name, callback_module, args})
  end


  #
  # GenServer Callbacks
  #


  @doc false
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
      
      {entity, initial_state, timeout} =
        case data do
          nil ->
            {initial_state, timeout} = callback_module.initialize(args) |> normalize_result()
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

  @doc false
  def handle_call(:state, _from, %{name: name, state: state} = data) do
    {:reply, state, data}
  end

  @doc false
  def handle_call({:stop, args}, _from, %{callback_module: callback_module, entity: entity, name: name, state: state} = data) do
    new_state = callback_module.stop(args, state)
    :ok = Registry.unregister_name(name)
    
    Db.transaction(fn ->
      Db.write(entity, name, :state, new_state)
    end)
    
    {:stop, :normal, :ok, Map.put(data, :state, new_state)}
  end

  @doc false
  def handle_call({:message, message}, _from,  %{callback_module: callback_module, name: name, state: state} = data) do
    
    {response, new_state} = callback_module.handle_message(message, state)
    
    {:reply, response, Map.put(data, :state, new_state)}
  end

  @doc false
  def handle_cast({:message, message}, %{callback_module: callback_module, name: name, state: state} = data) do
    
    {_response, new_state} = callback_module.handle_message(message, state)
    
    {:noreply, Map.put(data, :state, new_state)}
  end

  @doc false
  def handle_info(:run, %{callback_module: callback_module, name: name, state: state} = data) do
    
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
