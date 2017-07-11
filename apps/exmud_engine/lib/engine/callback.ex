defmodule Exmud.Engine.Callback do
  @moduledoc """
  An `Exmud.Object` can have an arbitrary number of callbacks associated with it.

  Callbacks are designed to be a more lightweight alternative to swapping out command sets when dynamic behavior on an
  object is required, but a more substantial change feels too heavy handed. There are a few special cases in which the
  engine will look for callbacks on an object, such as when an object is being puppeted/unpuppeted, or when commands
  are being processed.

  When a custom callback for an object has not been registered, a default implementation may be used instead. These can
  be specified by passing an atom to be used as a key to check the config, which is how the engine behaves for its
  internal hooks, or by passing a module name to be called directly. Default implementations have been provided for all
  engine hooks. This logic can be applied in application code as well when writing scripts and commands.
  """

  @doc """
  A callback module is an arbitrary hook to enable the insertion of custom logic into the processing flow of a command
  or script.
  """
  @callback execute(term) :: term

  alias Ecto.Multi
  alias Exmud.Engine.Repo
  alias Exmud.Engine.Schema.Callback
  import Ecto.Query
  import Exmud.Common.Utils
  import Exmud.Engine.Utils
  require Logger

  @callback_category "callback"


  #
  # API
  #

  def add(object_id, callback_string, callback_module) do
    args = %{string: callback_string, callback_module: serialize(callback_module), object_id: object_id}

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

  def add(%Ecto.Multi{} = multi, multi_key, object_id, callback_string, callback_module) do
    Multi.run(multi, multi_key, fn(_) ->
      add(object_id, callback_string, callback_module)
    end)
  end

  def get(object_id, callback_string) do
    case get(object_id, callback_string, nil) do
      {:ok, nil} -> {:ok, nil}
      result -> result
    end
  end

  def get!(object_id, callback_string) do
    case get(object_id, callback_string, nil) do
      {:ok, nil} -> {:error, :no_such_callback}
      result -> result
    end
  end

  def get(object_id, callback_string, default_callback_module) do
    case Repo.one(callback_query(object_id, callback_string)) do
      nil -> {:ok, default_callback_module}
      callback -> {:ok, deserialize(callback.callback_module)}
    end
  end

  def get(%Ecto.Multi{} = multi, multi_key, object_id, callback_string) do
    Multi.run(multi, multi_key, fn(_) ->
      get(object_id, callback_string)
    end)
  end

  def get!(%Ecto.Multi{} = multi, multi_key, object_id, callback_string) do
    Multi.run(multi, multi_key, fn(_) ->
      get!(object_id, callback_string)
    end)
  end

  def get(%Ecto.Multi{} = multi, multi_key, object_id, callback_string, default_callback_module) do
    Multi.run(multi, multi_key, fn(_) ->
      get(object_id, callback_string, default_callback_module)
    end)
  end

  def has(object_id, callback_string) do
    query =
      from callback in callback_query(object_id, callback_string),
        select: count("*")

    case Repo.one(query) do
      1 -> {:ok, true}
      0 -> {:ok, false}
    end
  end

  def has(%Ecto.Multi{} = multi, multi_key, object_id, callback_string) do
    Multi.run(multi, multi_key, fn(_) ->
      has(object_id, callback_string)
    end)
  end

  def delete(object_id, callback_string) do
    Repo.delete_all(callback_query(object_id, callback_string))
    |> case do
      {1, _} -> {:ok, object_id}
      {0, _} -> {:error, :no_such_callback}
      _ -> {:error, :unknown} # What are the error conditions? What needs to be handled?
    end
  end

  def delete(%Ecto.Multi{} = multi, multi_key, object_id, callback_string) do
    Multi.run(multi, multi_key, fn(_) ->
      delete(object_id, callback_string)
    end)
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

  def run(%Ecto.Multi{} = multi, multi_key, object_id, key, args) do
    Multi.run(multi, multi_key, fn(_) ->
      run(object_id, key, args)
    end)
  end

  @doc """
  A callback can only be registered with a unique key. This is primarily useful for a universal default callback when
  nothing more specific can be found attached to a given object. An example of this might be a `before_puppet`
  default callback which is essentially a no-op, allowing for a custom callback which could interrupt the puppeting
  process by returning `false`.
  """
  def register(key, callback_module) do
    Logger.debug("Registering callback for key `#{key}` with module `#{inspect(callback_module)}`")
    Cachex.set(cache(), key, callback_module)
  end

  @doc """
  Check to see if there is a callback module registered with a given key.
  """
  def registered(key) do
    Cachex.exists?(cache(), key)
  end

  @doc """
  Return the module that has been registered with a given key.
  """
  def which_module(key) do
    Logger.debug("Finding callback module for key `#{key}`")
    case Cachex.get(cache(), key) do
      {:missing, _} ->
        Logger.warn("Attempt to find callback module for key `#{key}` failed")
        {:error, :no_such_callback}
      result -> result
    end
  end

  @doc false
  def unregister(key) do
    Cachex.del(cache(), key)
  end


  #
  # Internal Functions
  #


  defp callback_query(object_id, callback_string) do
    from callback in Callback,
      where: callback.object_id == ^object_id
        and callback.string == ^callback_string
  end
end