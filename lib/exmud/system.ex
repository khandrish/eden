defmodule Exmud.System do
  @systemdoc """
  systems form the backbone of the engine. They drive time and event based
  actions, covering everything from weather effects to triggering AI actions.
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

  def purge(systems) when is_list(systems) do
    Db.transaction(fn ->
      systems
      |> Enum.each(fn(system) ->
        Db.find_with_all(system)
        |> Db.delete()
      end)
    end)

    systems
  end

  def purge(system) do
    purge([system])
    |> hd()
    |> elem(1)
  end

  def running?(systems) when is_list(systems) do
    systems
    |> Enum.map(fn(system) ->
      {system, Registry.whereis_name(system) != nil}
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
      {:ok, _} = Supervisor.start_child(Exmud.SystemSup, [system, args])
    end)

    systems
  end

  def start(system, args), do: hd(start([system], args))

  def start_link(system, args) do
    GenServer.start_link(__MODULE__, {system, args})
  end

  def state(systems) when is_list(systems) do
    systems
    |> Enum.map(fn(system) ->
      state = Registry.whereis_name(system)
      |> GenServer.call(:state)
      {system, state}
    end)
  end

  def state(system) do
    state([system])
    |> hd()
    |> elem(1)
  end

  def stop(systems, args \\ %{})
  def stop(systems, args) when is_list(systems) do
    systems
    |> Enum.each(fn(system) ->
      Registry.whereis_name(system)
      |> GenServer.call({:stop, args})
    end)

    systems
  end

  def stop(system, args), do: hd(stop([system], args))


  #
  # GenServer Callbacks
  #


  def init({system, args}) do
    result = Db.transaction(fn ->
      case Db.find_with_all(system) do
        [entity] -> {entity, Db.read(entity, system, :state)}
        [] -> nil
      end
    end)

    {entity, state} = case result do
      nil ->
        initial_state = system.initialize(args)
        Db.transaction(fn ->
          entity = Db.create()
          |> Db.write(system, :state, initial_state)
          {entity, initial_state}
        end)
       result -> result
    end

    Registry.register_name(system)

    {:ok, %{entity: entity, system: system, state: state}, 0}
  end

  def handle_call(:state, _from, %{state: state} = data) do
    {:reply, state, data}
  end

  def handle_call({:stop, args}, _from, %{state: state, system: system} = data) do
    new_state = system.stop(args, state)
    Registry.unregister_name(system)
    {:stop, :normal, :ok, Map.put(data, :state, new_state)}
  end

  def handle_call({:message, message}, _from, %{state: state, system: system} = data) do
    {response, new_state} = system.handle_message(message, state)
    {:reply, response, Map.put(data, :state, new_state)}
  end

  def handle_cast({:message, message}, %{state: state, system: system} = data) do
    {_response, new_state} = system.handle_message(message, state)
    {:noreply, Map.put(data, :state, new_state)}
  end

  def handle_info(:timeout, %{state: state, system: system} = data) do
    {new_state, timeout} = run(system, state)
    {:noreply, Map.put(data, :state, new_state), timeout}
  end

  defp run(system, state) do
    case system.run(state) do
      {_, _} = result -> result
      new_state -> {new_state, cfg(:default_system_run_timeout)}
    end
  end
end
