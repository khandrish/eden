defmodule Exmud.System do
  @moduledoc """
  systems form the backbone of the engine. They drive time and event based
  actions, covering everything from weather effects to triggering AI actions.
  """

  alias Exmud.Registry
  use GenServer

  def call(systems, message) when is_list(systems) do
    systems
    |> Enum.map(fn(system) ->
      response = Registry.find_by_name(system)
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
    |> Enum.each(fn(system) ->
      Registry.find_by_name(system)
      |> GenServer.cast({:message, message})
    end)

    systems
  end

  def cast(system, message) do
    cast([system], message)
    |> hd()
  end

  def deregister(systems, args \\ %{})
  def deregister(systems, args) when is_list(systems) do
    systems
    |> Enum.each(fn(system) ->
      Registry.find_by_name(system)
      |> GenServer.call({:terminate, args})
    end)

    systems
  end

  def deregister(system, args), do: hd(deregister([system], args))

  def register(systems, args \\ %{})
  def register(systems, args) when is_list(systems) do
    systems
    |> Enum.each(fn(system) ->
      {:ok, _} = Supervisor.start_child(Exmud.SystemSup, [system, args])
    end)

    systems
  end

  def register(system, args), do: hd(register([system], args))

  def registered?(systems) when is_list(systems) do
    systems
    |> Enum.map(fn(system) ->
      {system, Registry.name_registered?(system)}
    end)
  end

  def registered?(system) do
    registered?([system])
    |> hd()
    |> elem(1)
  end

  def running?(systems) when is_list(systems) do
    systems
    |> Enum.map(fn(system) ->
      result = Registry.find_by_name(system)
      |> GenServer.call(:running?)
      {system, result}
    end)
  end

  def running?(system) do
    running?([system])
    |> hd()
    |> elem(1)
  end

  def start(systems, args \\ %{})
  def start(systems, args) when is_list(systems) do
    systems
    |> Enum.each(fn(system) ->
      Registry.find_by_name(system)
      |> GenServer.call({:start, args})
    end)

    systems
  end

  def start(system, args), do: hd(start([system], args))

  def start_link(system, args) do
    GenServer.start_link(__MODULE__, {system, args})
  end

  def stop(systems, args \\ %{})
  def stop(systems, args) when is_list(systems) do
    systems
    |> Enum.each(fn(system) ->
      Registry.find_by_name(system)
      |> GenServer.call({:stop, args})
    end)

    systems
  end

  def stop(system, args), do: hd(stop([system], args))

  #
  # GenServer Callbacks
  #

  def init({module, args}) do
    Registry.register_name(module)
    # check for state
    # if exists read it
    # if not use default value
    state = Execs.transaction(fn ->
      case Execs.find_with_all(__MODULE__) do
        [entity] -> {entity, Execs.read(entity, __MODULE__, :state)}
        [] ->
          Execs.create()
          |> Execs.write(__MODULE__, :state, %{})
          {entity, %{}}
      end
    end)
    state = module.initialize(args, state)

    {:ok, %{state: state, module: module, running: false}}
  end

  def handle_call(:running?, _from, %{running: running} = data) do
    {:reply, running, data}
  end

  def handle_call({:terminate, args}, _from, %{state: state, module: module} = data) do
    new_state = module.terminate(args, state)
    {:stop, :normal, :ok, Map.merge(data, %{state: new_state, running: false})}
  end

  def handle_call({:start, args}, _from, %{state: state, module: module} = data) do
    new_state = module.start(args, state)
    {:reply, :ok, Map.merge(data, %{state: new_state, running: true})}
  end

  def handle_call({:stop, args}, _from, %{state: state, module: module} = data) do
    new_state = module.stop(args, state)
    {:reply, :ok, Map.merge(data, %{state: new_state, running: false})}
  end

  def handle_call({:message, message}, _from, %{state: state, module: module} = data) do
    {response, new_state} = module.handle_message(message, state)
    {:reply, response, Map.put(data, :state, new_state)}
  end

  def handle_cast({:message, message}, %{state: state, module: module} = data) do
    {_response, new_state} = module.handle_message(message, state)
    {:noreply, Map.put(data, :state, new_state)}  end

  def terminate(_reason, %{module: module} = _data) do
    Registry.unregister_name(module)
  end
end
