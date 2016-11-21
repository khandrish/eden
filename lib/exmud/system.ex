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
  Invoked when a message has been sent to the service.
  
  Must return a tuple in the form of `{reply, state}`. If the message was sent
  as a cast the value of `reply` is ignored.
  """
  @callback handle_message(message, state) :: {reply, state}
  
  @doc """
  Invoked the first time a service is started. This callback will be invoked
  before `start/2`.
  
  Must return a new state. This will be the state used by all other callbacks.
  """
  @callback initialize(args) :: state
  
  @doc """
  Invoked when the main loop of the service is to be run again.
  
  Must return a new state.
  """
  @callback run(args) :: state
  
  @doc """
  Invoked when the service is being started.
  
  Must return a new state.
  """
  @callback start(args, state) :: state
  
  @doc """
  Invoked when the service is being stopped.
  
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
                [entity] ->
                  Db.read(entity, name, :state)
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
