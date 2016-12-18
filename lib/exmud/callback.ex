defmodule Exmud.Callback do
  @moduledoc """
  An `Exmud.GameObject` can have an arbitrary number of callbacks associated
  with it.
  
  These callbacks provide the hooks for the engine, and application code, to
  customize almost every aspect of how the engine interacts with a game object.
  
  A callback, in this context, is a module which implements the
  `Exmud.Callback` behavior and which is registered with the engine. When a
  game object is being processed, the object will be checked for registered
  callbacks matching what the engine needs to call. If a custom implementation
  is not found the engine will fall back to a default implementation.
  """
  
  alias Exmud.Registry
  alias Exmud.Repo
  alias Exmud.Schema.Callback
  alias Exmud.Schema.GameObject
  import Ecto.Query
  import Exmud.Utils
  require Logger
  
  @callback_category "callback"
  
  
  #
  # API
  #
  
  
  # Management of callbacks within the engine
  
  @doc """
  In order for the engine to map callback strings to callback modules, each
  callback module must be registered with the engine via a unique key.
  """
  def register(key, callback_module) do
    Logger.debug("Registering callback for key `#{key}` with module `#{callback_module}`")
    Registry.register_key(key, @callback_category, callback_module)
  end
  
  def registered?(key) do
    Registry.key_registered?(key, @callback_category)
  end
  
  def which_module(key) do
    Logger.debug("Finding callback module for key `#{key}`")
    case Registry.read_key(key, @callback_category) do
      {:error, _} ->
        Logger.warn("Attempt to find callback module for key `#{key}` failed")
        {:error, :no_such_callback}
      result -> result
    end
  end
  
  def unregister(key) do
    Registry.unregister_key(key, @callback_category)
  end
  
  # Manipulation of callbacks on an object
  
  def add(oid, callback, key) do
    args = %{callback: callback, key: key, oid: oid}
    Repo.insert(Callback.changeset(%Callback{}, args))
    |> normalize_noreturn_result()
    |> case do
      {:error, errors} ->
        if Keyword.has_key?(errors, :oid) do
          Logger.warn("Attempt to add callback onto non existing object `#{oid}` failed")
          {:error, :no_such_game_object}
        else
          {:error, errors}
        end
      result ->
        result
    end
  end
  
  def get(oid, callback, default) do
    case Repo.one(callback_query(oid, callback)) do
      nil -> which_module(default)
      callback -> which_module(callback.key)
    end
  end
  
  def has?(oid, callback) do
    case Repo.one(callback_query(oid, callback)) do
      nil -> {:ok, false}
      object -> {:ok, true}
    end
  end
  
  def list(callbacks) do
    Exmud.GameObject.list(callbacks: List.wrap(callbacks))
  end
  
  def delete(oid, callback) do
    Repo.delete_all(callback_query(oid, callback))
    |> case do
      {1, _} -> :ok
      {0, _} -> {:error, :no_such_callback}
      _ -> {:error, :unknown}
    end
  end
  
  
  #
  # Private functions
  #
  
  
  defp callback_query(oid, callback) do
    from callback in Callback,
      where: callback.callback == ^callback,
      where: callback.oid == ^oid
  end
end