defmodule Exmud.Engine.Callback do
  @moduledoc """
  An `Exmud.Object` can have an arbitrary number of Callbacks associated with it.

  Callbacks are designed to work alongside Commands when dynamic behavior on an Object is required. Much like Commands
  are added/removed on Objects via Command Sets, Callbacks are added/removed from Objects via Callback Sets.

  Designed to be called from within context of a Command, Callbacks can be used for a variety of different tasks such
  as modifying a string before it gets sent, or sending a message after a certain event has taken place.

  When a custom Callback for an Object has not been registered, a default implementation may be used instead. These can
  be specified by passing a name to be used to lookup a default module, which is how the engine behaves for its
  internal hooks, or by passing a function to be called directly. Default implementations have been provided for all
  engine hooks. This logic can be applied in application code as well as when writing Scripts and Commands.

  Callbacks have two different methods of being identified that are used in different ways. The key and the name. The
  name is a unique string that identifies a Callback module within the Engine and is useful for not only exploring the
  state of the Engine, but for providing default fallbacks if a matching Callback key cannot be found on an Object.

  Callback keys are unique per-object, with the addition of a second overwriting the first, and are used for behavior
  hooks at runtime. In the example of an Object being puppeted, the Engine will first look for a Callback on an Object
  with the key "pre_puppet", and if it cannot find one will look for a named default implementation. The provided
  default "pre_puppet" Callback checks the Locks on an Object to make sure the one doing the puppeting has permission.

  Note that all methods in this module, and all Callback modules/functions, are executed in the context of the calling
  process.
  """

  alias Ecto.Multi
  alias Exmud.Engine.Cache
  alias Exmud.Engine.ObjectUtil
  alias Exmud.Engine.Repo
  alias Exmud.Engine.Schema.Callback
  import Ecto.Query
  import Exmud.Common.Utils
  import Exmud.Engine.Utils
  require Logger


  #
  # Behavior definition and default callback setup
  #


  @doc false
  defmacro __using__(_) do
    quote location: :keep do

      @behaviour Exmud.Engine.Callback

      @doc false
      def name, do: Atom.to_string(__MODULE__)

      @doc false
      def run(command, _args), do: command

      defoverridable [name: 0,
                      run: 2]
    end
  end

  @doc """
  The unique name of the Callback.

  This unique string is used for registration in the Engine, and can be used to both attach Callbacks to an Object as
  well as provide a default name for when a Callback does not exist on an Object.
  """
  @callback name :: String.t

  @doc """
  Called when the Engine determines the Callback should be executed.

  The Callback is called with the Command struct, containing all the necessary information to execute on a Command, and
  the optional initialized args. It must return a new command object.
  """
  @callback run(command, args) :: command

  @typedoc "Arguments passed through to a callback module."
  @type args :: term

  @typedoc "The Command struct representing the state of the Command being processed."
  @type command :: term


  #
  # API
  #


  @doc """
  Attach a Callback to an Object.
  """
  def attach(object_id, callback_key, callback_name, config \\ nil) do
    with {:ok, _} <- lookup(callback_name) do
      record = Callback.new(%{key: callback_key, name: callback_name, object_id: object_id, data: pack_term(config)})
      ObjectUtil.attach(record)
    end
  end

  @doc """
  Detach a Callback from an Object.
  """
  def detach(object_id, key) do
    Repo.delete_all(callback_query(object_id, key))
    |> case do
      {1, _} -> :ok
      {0, _} -> {:error, :no_such_callback}
    end
  end

  @doc """
  Get the Callback attached to an Object by its key.

  Providing an optional default callback to fall back to can be done by providing the name of the Callback to look up
  in the Engine registry. In either case, the callback registered with the Engine will be looked up by its name.
  Changing the name of a Callback module is not advised once it has been used for this reason, unless done deliberately.
  """
  def get(object_id, key, default_callback_name \\ nil) do
    case Repo.one(callback_query(object_id, key)) do
      nil -> # No matching Callback found on Object
        if default_callback_name != nil do # Default Callback name has been provided
          lookup(default_callback_name)
        else # No default Callback name has been provided
          {:error, :no_such_callback}
        end
      callback -> # Callback has been found on Object
        lookup(callback.name)
    end
  end

  @doc """
  Check if a Callback is attached to an Object.
  """
  def is_attached?(object_id, key) do
    query =
      from callback in callback_query(object_id, key),
        select: count("*")

    Repo.one(query) == 1
  end


  @doc """
  When running a callback, the engine first checks to see if there is an object specific implementation before falling
  back to a globally registered implementation. If no global implementation is found an error is returned.
  """
  def run(object_id, key, command, args, default_callback_name \\ nil) do
    case get(object_id, key, default_callback_name) do
      {:ok, callback} ->
        apply(callback, :run, [command, args])
      error ->
        error
    end
  end


  #
  # Manipulation of Callbacks in the Engine.
  #


  @cache :callback_cache

  @doc """
  List all Callbacks currently registered with the Engine.
  """
  def list_registered() do
    Logger.info("Listing all registered Callbacks")
    Cache.list(@cache)
  end

  @doc """
  Return the Callback module that has been registered with a given name.
  """
  def lookup(name) do
    case Cache.get(@cache, name) do
      {:error, _} ->
        Logger.error("Lookup failed for Callback registered with name `#{name}`")
        {:error, :no_such_callback}
      result ->
        Logger.info("Lookup succeeded for Callback registered with name `#{name}`")
        result
    end
  end

  @doc """
  Callbacks are registered with the Engine via a unique name.

  Takes in a Callback module, calling the 'name/0' method on said module, and registers it with the Engine. Registering
  a second module with the same name as a previous one will overwrite the first entry.
  """
  def register(callback_module) do
    Logger.info("Registering Callback with name `#{callback_module.name()}` and module `#{inspect(callback_module)}`")
    Cache.set(@cache, callback_module.name(), callback_module)
  end

  @doc """
  Check to see if there is a Callback module registered with a given name.
  """
  def registered?(callback_module) do
    Logger.info("Checking registration of Callback with name `#{callback_module.name()}`")
    Cache.exists?(@cache, callback_module.name())
  end

  @doc """
  Unregister a call default Callback from the system.
  """
  def unregister(callback_module) do
    Logger.info("Unregistering Callback with name `#{callback_module.name()}`")
    Cache.delete(@cache, callback_module.name())
  end


  #
  # Internal Functions
  #


  defp callback_query(object_id, key) do
    from callback in Callback,
      where: callback.object_id == ^object_id
        and callback.key == ^key
  end
end