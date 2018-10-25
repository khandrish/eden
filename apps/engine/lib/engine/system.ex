defmodule Exmud.Engine.System do
  @moduledoc """
  Systems form the backbone of the Engine, driving time and message based actions within the game world.

  Examples include weather effects, triggering invasions, regular spawning of critters, the day/night cycle, and so on. Unlike Scripts, which can be added to as many different Objects as you want, only one instance of a System may run at a time.

  Systems can transition between a set schedule, dynamic schedule, and purely message based seamlessly at runtime simply by modifying the value returned from the `run/1` callback. Note that while it is possible to run only in response to being explicitly called, short of not implementing the `handle_message/2` callback it is not possible for the Engine to run in a schedule only mode. Only you can prevent messages by not calling the System directly in your code.

  Under the hood, Systems are simply Scripts which are treated just a little bit differently. That said, you must not use the same callback module for a System as you do for a Script. It will cause odd and unexpected things to happen.
  """

  defmodule Result do
    defstruct [ :events, :next_iteration, :state ]
  end

  @doc false
  defmacro __using__(_) do
    quote location: :keep do
      @behaviour Exmud.Engine.System
      alias Exmud.Engine.System.Result

      @doc false
      def handle_message( message, state ), do: { :ok, message, %Result{ state: state } }

      @doc false
      def initialize( args ), do: { :ok, %Result{ state: nil } }

      @doc false
      def run( state ), do: { :ok, %Result{ state: state } }

      @doc false
      def start( _args, state ), do: { :ok, %Result{ do: 0, state: state } }

      @doc false
      def stop( _args, state ), do: { :ok, %Result{ state: state } }

      defoverridable handle_message: 2,
                     initialize: 1,
                     run: 1,
                     start: 2,
                     stop: 2
    end
  end

  #
  # Behavior definition and default callback setup
  #

  @doc """
  Handle a message which has been explicitly sent to the System.
  """
  @callback handle_message( message, state ) :: { :ok, reply, state } | { :error, reason }

  @doc """
  Called only once when a System is first initialized.

  The state returned from this function will be passed to the `start/2` callback.
  """
  @callback initialize( args ) :: { :ok, state } | { :error, reason }

  @doc """
  Called in response to an interval period expiring, or an explicit call to run the System again.
  """
  @callback run( state ) ::
              { :ok, state }
              | { :ok, state, next_iteration }
              | { :stop, reason, state }
              | { :error, error, state }
              | { :error, error, state, next_iteration }

  @doc """
  Called when the System is being started.

  Must return a new state and an optional timeout, in milliseconds, until the next iteration.
  """
  @callback start( args, state ) :: { :ok, state } | { :ok, state, next_iteration } | { :error, error }

  @doc """
  Called when the System is being stopped.

  Must return a new state which will be persisted.
  """
  @callback stop( args, state ) :: { :ok, state } | { :error, error }

  @typedoc "Arguments passed through to a callback module."
  @type args :: term

  @typedoc "A message passed through to a callback module."
  @type message :: term

  @typedoc "How many milliseconds should pass until the run callback is called again."
  @type next_iteration :: integer

  @typedoc "A reply passed through to the caller."
  @type reply :: term

  @typedoc "An error message passed through to the caller."
  @type error :: term

  @typedoc "The reason the System is stopping."
  @type reason :: term

  @typedoc "State used by the callback module."
  @type state :: term

  @typedoc "Id of the Object representing the System within the Engine."
  @type object_id :: integer

  @typedoc "The callback_module that is the implementation of the System logic."
  @type callback_module :: atom

  #
  # API
  #

  alias Exmud.Engine.ObjectUtil
  alias Exmud.Engine.Repo
  alias Exmud.Engine.Schema.System
  alias Exmud.Engine.Worker.SystemWorker
  import Ecto.Query
  import Exmud.Common.Utils
  import Exmud.Engine.Utils
  import Exmud.Engine.Constants
  require Logger

  @system_registry system_registry()

  @doc """
  Call a running System with a message.
  """
  @spec call( callback_module, message ) :: { :ok, reply }
  def call( callback_module, message ) when is_atom( callback_module ) do
    send_message( :call, callback_module, { :message, message } )
  end

  @doc """
  Cast a message to a running System.
  """
  @spec cast( callback_module, message ) :: :ok
  def cast( callback_module, message ) when is_atom( callback_module ) do
    send_message( :cast, callback_module, { :message, message } )

    :ok
  end

  @doc """
  Get the state of a System.
  """
  @spec get_state( callback_module ) :: { :ok, term } | { :error, :no_such_system }
  def get_state( callback_module ) when is_atom( callback_module ) do
    try do
      GenServer.call( via( @system_registry, callback_module ), :state, :infinity )
    catch
      :exit, { :noproc, _ } ->
        system_query( callback_module )
        |> Repo.one()
        |> case do
          nil ->
            { :error, :no_such_system }

          system ->
            { :ok, deserialize( system.state ) }
        end
    end
  end

  @doc """
  Purge System data from the database. Does not check if System is running
  """
  @spec purge( callback_module ) :: :ok | { :error, :no_such_system }
  def purge( callback_module ) when is_atom( callback_module ) do
    system_query( callback_module )
    |> Repo.one()
    |> case do
      nil ->
        { :error, :no_such_system }

      system ->
        { :ok, _ } = Repo.delete( system )
        :ok
    end
  end

  @doc """
  Trigger a System to run immediately. If a System is running while this call is made the System will run again as soon as it can and the result of that run is returned.

  This method ensures that the System is active and that it will begin the process of running its main loop immediately, but offers no other guarantees.
  """
  @spec run( callback_module ) :: :ok | { :error, :no_such_system }
  def run( callback_module ) when is_atom( callback_module ) do
    send_message( :call, callback_module, :run )
  end

  @doc """
  Check to see if a system is running.
  """
  @spec running?( callback_module ) :: boolean
  def running?( callback_module ) when is_atom( callback_module ) do
    send_message( :call, callback_module, :running ) == true
  end

  @doc """
  Start a System which must already be initialized.
  """
  @spec start( callback_module, args :: term ) :: :ok | { :error, :not_initialized }
  def start( callback_module, start_args \\ nil ) when is_atom( callback_module ) do
    gen_server_args = [
      callback_module,
      start_args
    ]

    with { :ok, _ } <-
           DynamicSupervisor.start_child(
             Exmud.Engine.CallbackSupervisor,
             { SystemWorker, gen_server_args }
           ) do
      :ok
    end
  end

  @doc """
  Initialize a System.
  """
  @spec initialize( callback_module, args | nil ) :: :ok | { :error, :no_such_system }
  def initialize( callback_module, config \\ nil ) do
    initialization_result =
      apply( callback_module, :initialize, [ config ] )

      case initialization_result do
        { :ok, new_state } ->
          Logger.info( "System `#{ callback_module }` successfully initialized." )


          %{ callback_module: pack_term( callback_module ), state: pack_term( new_state ) }
          |> Exmud.Engine.Schema.System.new()
          |> Repo.insert!

          :ok

        {_, error} = error_result ->
          Logger.error( "Encountered error `#{ error }` while initializing System."   )

          error_result
      end
  end

  @doc """
  Stops a System if it is started.
  """
  @spec stop( callback_module ) :: :ok | { :error, :no_such_system }
  def stop( callback_module ) do
    case Registry.lookup( @system_registry, callback_module ) do
      [ { pid, _ } ] ->
        ref = Process.monitor( pid )
        GenServer.stop( pid, :normal )

        receive do
          { :DOWN, ^ref, :process, ^pid, :normal } ->
            :ok
        end

      _ ->
        { :error, :no_such_system }
    end
  end

  @doc """
  Update the state of a System in the database.

  Primarily used by the Engine to persist the state of a running System whenever it changes.
  """
  @spec update( callback_module, state ) :: :ok | { :error, :no_such_system }
  def update( callback_module, state ) do
    query = system_query( callback_module )

    case Repo.update_all( query, set: [ state: pack_term( state ) ] ) do
      { 1, _ } -> :ok
      _ -> { :error, :no_such_system }
    end
  end

  #
  # Internal Functions
  #

  @spec send_message( method :: atom, callback_module, message ) ::
          :ok | { :ok, term } | { :error, :system_not_running }
  defp send_message( method, callback_module, message ) do
    try do
      apply( GenServer, method, [ via( @system_registry, callback_module ), message ] )
    catch
      :exit, _ -> { :error, :no_such_system }
    end
  end

  defp system_query( callback_module ) do
    from( system in System, where: system.callback_module == ^pack_term( callback_module ) )
  end
end
