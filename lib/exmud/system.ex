defmodule Exmud.System do
  @systemdoc """
  Systems form the backbone of the engine. They drive time and event based
  actions, covering everything from weather effects to triggering AI actions.
  
  Systems do not have to run on a set schedule and instead can only react to
  events, and vice versa. 
  """

  alias Exmud.Db
  alias Exmud.Registry


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
end
