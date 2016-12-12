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
    Registry.register_key(key, @callback_category, callback_module)
  end
  
  def registered?(key) do
    Registry.key_registered?(key, @callback_category)
  end
  
  def which_module(key) do
    Registry.read_key(key, @callback_category)
  end
  
  def unregister(key) do
    Registry.unregister_key(key, @callback_category)
  end
  
  # Manipulation of callbacks on an object
  
  def put(oid, callback, key) do
    args = %{callback: callback, key: key, oid: oid}
    Repo.insert(Callback.changeset(%Callback{}, args))
    |> normalize_noreturn_result()
  end
  
  def has?(oid, callback) do
    case Repo.one(find_callback_query(oid, callback)) do
      nil -> {:error, :no_such_game_object}
      object -> {:ok, length(object.callbacks) == 1}
    end
  end
  
  def delete(oid, callback) do
    Repo.delete_all(
      from callback in Callback,
        where: callback.oid == ^oid,
        where: callback.callback == ^callback
    )
    |> case do
      {1, _} -> :ok
      {0, _} -> {:error, :no_such_callback}
      _ -> {:error, :unknown}
    end
  end
  
  
  #
  # Private functions
  #
  
  
  defp find_callback_query(oid, callback) do
    from object in GameObject,
      left_join: callback in assoc(object, :callbacks), on: object.id == callback.oid,
      where: object.id == ^oid or callback.callback == ^callback and object.id == ^oid,
      preload: [callbacks: callback]
  end
end