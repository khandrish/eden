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

  @callback_cache_category "callback"


  #
  # API
  #


  def add(object_id, key, callback_function) do
    args = %{key: key, callback_function: serialize(callback_function), object_id: object_id}

    Callback.add(%Callback{}, args)
    |> Repo.insert()
    |> normalize_repo_result(object_id)
    |> case do
      {:error, errors} ->
        if Keyword.has_key?(errors, :object_id) do
          Logger.warn("Attempt to add callback onto non existing object `#{object_id}`")
          {:error, :no_such_object}
        else
          {:error, errors}
        end
      result -> result
    end
  end

  def get(object_id, key) do
    case get(object_id, key, nil) do
      {:ok, nil} -> {:ok, nil}
      result -> result
    end
  end

  def get!(object_id, key) do
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

  def has(object_id, key) do
    query =
      from callback in callback_query(object_id, key),
        select: count("*")

    case Repo.one(query) do
      1 -> {:ok, true}
      0 -> {:ok, false}
    end
  end

  def delete(object_id, key) do
    Repo.delete_all(callback_query(object_id, key))
    |> case do
      {1, _} -> {:ok, object_id}
      {0, _} -> {:error, :no_such_callback}
      _ -> {:error, :unknown} # What are the error conditions? What needs to be handled?
    end
  end


  @doc """
  When running a callback, the engine first checks to see if there is an object specific implementation before falling
  back to a default implementation. If no default implementation is found an error is returned.
  """
  def run(object_id, key, args) do
    case get(object_id, key) do
      {:ok, callback} ->
        callback.run(object_id, args)
      _error ->
        {:error, :no_such_callback}
    end
  end

  @doc """
  A callback can only be registered with a unique key. This is primarily useful for a universal default callback when
  nothing more specific can be found attached to a given object. An example of this might be a `before_puppet`
  default callback which is essentially a no-op, allowing for a custom callback which could interrupt the puppeting
  process by returning `false`.
  """
  def register(key, callback_function) do
    Logger.debug("Registering callback for key `#{key}` with module `#{inspect(callback_function)}`")
    Cache.set(@callback_cache_category, key, callback_function)
  end

  @doc """
  Check to see if there is a callback module registered with a given key.
  """
  def registered(key) do
    Cache.exists?(@callback_cache_category, key)
  end

  @doc """
  Return the module that has been registered with a given key.
  """
  def get_registered(key) do
    Logger.debug("Finding registered callback for key `#{key}`")
    case Cache.get(@callback_cache_category, key) do
      {:missing, _} ->
        Logger.warn("Attempt to find callback module for key `#{key}` failed")
        {:error, :no_such_callback}
      result -> result
    end
  end

  @doc false
  def unregister(key) do
    Cache.delete(@callback_cache_category, key)
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