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
  import Ecto.Query
  import Exmud.Utils
  require Logger
  
  @callback_category "callback"
  
  
  #
  # API
  #
  
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
end