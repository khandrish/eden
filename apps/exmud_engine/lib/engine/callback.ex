defmodule Exmud.Engine.Callback do
  @moduledoc """
  An `Exmud.Object` can have an arbitrary number of callbacks associated with it.

  Callbacks are designed to be a more lightweight alternative to swapping out command sets when dynamic behavior on an
  object is required, but a more substantial change feels too heavy handed. There are a few special cases in which the
  engine will look for callbacks on an object, such as when an object is being puppeted/unpuppeted, or when commands
  are being processed.

  When a custom callback for an object has not been registered, a default implementation may be used instead. These can
  be specified by passing a key to be used as a key to check the config, which is how the engine behaves for its
  internal hooks, or by passing a function to be called directly. Default implementations have been provided for all
  engine hooks. This logic can be applied in application code as well when writing scripts and commands.
  """

  alias Exmud.Engine.Cache
  alias Exmud.Engine.Repo
  alias Exmud.Engine.Schema.Callback
  import Ecto.Query
  import Exmud.Common.Utils
  require Logger


  #
  # Adding callback to an object
  #


  def add(object_id, key, callback_function) do
    args = %{key: key, callback_function: serialize(callback_function), object_id: object_id}

    Callback.add(%Callback{}, args)
    |> Repo.insert()
    |> normalize_repo_result(object_id)
    |> case do
      {:error, errors} ->
        if Keyword.has_key?(errors, :object_id) do
          Logger.error("Attempt to add Callback onto non existing object `#{object_id}`")
          {:error, :no_such_object}
        else
          {:error, errors}
        end
      result -> result
    end
  end


  #
  # Get callback from object.
  #


  def get(object_id, key) do
    case get(object_id, key, nil) do
      {:ok, nil} -> {:error, :no_such_callback}
      result -> result
    end
  end

  def get(object_id, key, default_callback_function) do
    case Repo.one(callback_query(object_id, key)) do
      nil -> {:ok, default_callback_function}
      callback -> {:ok, deserialize(callback.callback_function)}
    end
  end


  #
  # Check presence of callback on an Object.
  #


  def has(object_id, key) do
    query =
      from callback in callback_query(object_id, key),
        select: count("*")

    case Repo.one(query) do
      1 -> {:ok, true}
      0 -> {:ok, false}
    end
  end


  #
  # Remove callback from an Object.
  #


  def remove(object_id, key) do
    Repo.delete_all(callback_query(object_id, key))
    |> case do
      {1, _} -> {:ok, object_id}
      {0, _} -> {:error, :no_such_callback}
      _ -> {:error, :unknown} # What are the error conditions? What needs to be handled?
    end
  end


  @doc """
  When running a callback, the engine first checks to see if there is an object specific implementation before falling
  back to a globally registered implementation. If no global implementation is found an error is returned.
  """
  def run(object_id, key, args) do
    case get(object_id, key) do
      {:ok, callback} ->
        apply(callback, [object_id, args])
      _error ->
        case lookup(key) do
          {:ok, callback} ->
            apply(callback, [object_id, args])
          _error ->
            {:error, :no_such_callback}
        end
    end
  end


  #
  # Manipulation of Callbacks in the Engine.
  #

  @cache :callback_cache

  def list_registered() do
    Logger.info("Listing all registered Callbacks")
    Cache.list(@cache)
  end

  @doc """
  Return the module that has been registered with a given key.
  """
  def lookup(key) do
    case Cache.get(@cache, key) do
      {:error, _} ->
        Logger.error("Lookup failed for Callback registered with key `#{key}`")
        {:error, :no_such_callback}
      result ->
        Logger.info("Lookup succeeded for Callback registered with key `#{key}`")
        result
    end
  end

  @doc """
  A callback can only be registered with a unique key. This is primarily useful for a universal default callback when
  nothing more specific can be found attached to a given object. An example of this might be a `before_puppet`
  default callback which is essentially a no-op, allowing for a custom callback which could interrupt the puppeting
  process by returning `false`.
  """
  def register(key, callback_module) do
    Logger.info("Registering Callback with key `#{key}` and module `#{inspect(callback_module)}`")
    Cache.set(@cache, key, callback_module)
  end

  @doc """
  Check to see if there is a callback module registered with a given key.
  """
  def registered?(key) do
    Logger.info("Checking registration of Callback with key `#{key}`")
    Cache.exists?(@cache, key)
  end

  @doc """
  Unregister a call default callback from the system.
  """
  def unregister(key) do
    Logger.info("Unregistering Callback with key `#{key}`")
    Cache.delete(@cache, key)
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