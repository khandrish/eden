defmodule Exmud.Engine.Script do
  @moduledoc """
  Scripts perform repeated logic on one or, usually, more Objects within the game world.

  Examples include a character slowly drying off, a wound draining vitality, an opened door automatically closing, and
  so on. They can control longer running logic such as AI behaviors that are meant to remain on the Object permanently,
  and shorter one off tasks where the script will be removed after a single run.
  """


  #
  # Behavior definition and default callback setup
  #


  @doc """
  Called the first, and only the first, time a Script is started on an Object.

  If called, it will immediately precede `start/2` and the returned value(s) will be passed to the `start/2` callback.
  If a Script has been previously initialized, the persisted state is loaded from the database and used in the `start/2`
  callback instead.
  """
  @callback initialize(object_id, args) :: {:ok, state} | {:error, reason}

  @doc """
  Called in response to an interval period expiring, or an explicit call to start the System again.
  """
  @callback run(object_id, state) :: {:ok, state} |
                                     {:ok, state, next_iteration} |
                                     {:stop, reason, state} |
                                     {:error, error, state}

  @doc """
  Called when the system is being started.

  Must return a new state.
  """
  @callback start(args, state) :: {:ok, state} | {:ok, state, next_iteration} | {:error, error}

  @doc """
  Called when the system is being stopped.

  Must return a new state which will be persisted.
  """
  @callback stop(args, state) :: {:ok, state} | {:error, error}

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

  @typedoc "Id of an Object."
  @type object_id :: term

  alias Exmud.Engine.Cache
  require Logger


  #
  # Manipulation of Scripts in the Engine.
  #

  @cache :script_cache

  def list_registered() do
    Logger.info("Listing all registered Scripts")
    Cache.list(@cache)
  end

  def lookup(key) do
    case Cache.get(@cache, key) do
      {:error, _} ->
        Logger.error("Lookup failed for Script registered with key `#{key}`")
        {:error, :no_such_script}
      result ->
        Logger.info("Lookup succeeded for Script registered with key `#{key}`")
        result
    end
  end

  def register(key, callback_module) do
    Logger.info("Registering Script with key `#{key}` and module `#{inspect(callback_module)}`")
    Cache.set(@cache, key, callback_module)
  end

  def registered?(key) do
    Logger.info("Checking registration of Script with key `#{key}`")
    Cache.exists?(@cache, key)
  end

  def unregister(key) do
    Logger.info("Unregistering Script with key `#{key}`")
    Cache.delete(@cache, key)
  end
end