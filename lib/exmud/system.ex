defmodule Exmud.System do
  @moduledoc """
  A behaviour module for implementing a system within the Exmud engine.
  
  Systems form the backbone of the engine. They drive time and event based
  actions, covering everything from weather effects to triggering AI actions.
  
  Systems do not have to run on a set schedule and instead can only react to
  events, and vice versa. See documentation for `c:initialize/1` for details.
  
  ## Callbacks
  There are 5 callbacks required to be implemented in a system. By adding
  `use Exmud.System` to your module, Elixir will automatically define all
  5 callbacks for you, leaving it up to you to implement the ones
  you want to customize.
  """


  #
  # Behavior definition and default callback setup
  #


  @doc """
  Invoked when a message has been sent to the system.
  
  Must return a tuple in the form of `{reply, state}`. If the message was sent
  as a cast the value of `reply` is ignored.
  """
  @callback handle_message(message, state) :: {reply, state}
  
  @doc """
  Invoked the first time a system is started. This callback will be invoked
  before `start/2`.
  
  Must return a new state. This will be the state used by all other callbacks.
  """
  @callback initialize(args) :: state
  
  @doc """
  Invoked when the main loop of the system is to be run again.
  
  Must return a new state.
  """
  @callback run(args) :: state
  
  @doc """
  Invoked when the system is being started.
  
  Must return a new state.
  """
  @callback start(args, state) :: state
  
  @doc """
  Invoked when the system is being stopped.
  
  Must return a new state.
  """
  @callback stop(args, state) :: state

  @typedoc "Arguments passed through to a callback module."
  @type args :: term
  
  @typedoc "A message passed through to a callback module."
  @type message :: term
  
  @typedoc "A reply passed through to the caller."
  @type reply :: term
  
  @typedoc "State used by the callback module."
  @type state :: term
  
  @doc false
  defmacro __using__(_) do
    quote location: :keep do
      @behaviour Exmud.System
      
      @doc false
      def handle_message(message, state), do: {message, state}
      
      @doc false
      def initialize(args), do: Map.new()
      
      @doc false
      def run(state), do: state
      
      @doc false
      def start(_args, state), do: state
      
      @doc false
      def stop(_args, state), do: state

      defoverridable [handle_message: 2,
                      initialize: 1,
                      run: 1,
                      start: 2,
                      stop: 2]
    end
  end


  #
  # API
  #
  

  alias Exmud.Db
  alias Exmud.Registry


  def call(systems, message) when is_list(systems) do
    systems
    |> Enum.map(fn(system) ->
      response =
        case Registry.whereis_name(system) do
          nil -> {:error, :no_such_system}
          pid ->
            GenServer.call(pid, {:message, message})
        end

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
      case Registry.whereis_name(system) do
        nil -> {:error, :no_such_system}
        pid ->
          GenServer.cast(pid, {:message, message})
          system
      end
    end)
  end

  def cast(system, message) do
    cast([system], message)
    |> hd()
  end

  def purge(systems) when is_list(systems) do
    initial_results = for system <- systems, into: %{}, do: {system, nil}
  
    Db.transaction(fn ->
      entities = Db.find_with_any(systems)
      data = Db.read(entities, systems)
      Db.delete(entities, systems)
      data
    end)
    |> Enum.reduce(initial_results, fn(entity, results) ->
      components = entity.components
      system = Map.keys(components) |> hd()
      state = Map.values(components) |> hd() |> Map.get(:state)
      Map.put(results, system, state)
    end)
    |> Map.to_list()
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

  def start(definitions, args \\ %{})
  def start(definitions, args) when is_list(definitions) do
    definitions
    |> Enum.map(fn(definition) ->
      {system, callback_module} =
        case definition do
          {_, _} = result -> result
          callback_module -> {callback_module, callback_module}
        end
        
      case Supervisor.start_child(Exmud.SystemSup, [system, callback_module, args]) do
        {:ok, _} -> system
        {:error, {_, reason}} -> {:error, reason}
      end
    end)
  end

  def start(definition, args) do
    start([definition], args)
    |> hd()
  end

  def state(systems) when is_list(systems) do
    systems
    |> Enum.map(fn(system) ->
      state = 
        case Registry.whereis_name(system) do
          nil ->
            Db.transaction(fn ->
              case Db.find_with_all(system) do
                [] -> nil
                [entity] ->
                  Db.read(entity, system, :state)
              end
            end)
          pid ->
            GenServer.call(pid, :state)
        end
      
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
    Enum.map(systems, fn(system) ->
      case Registry.whereis_name(system) do
        nil -> {:error, :no_such_system}
        pid ->
          GenServer.call(pid, {:stop, args})
          system
      end
    end)
  end

  def stop(system, args), do: hd(stop([system], args))
end
