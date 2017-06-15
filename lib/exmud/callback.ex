defmodule Exmud.Callback do
  @moduledoc """
  An `Exmud.Object` can have an arbitrary number of callbacks associated with it.

  Callbacks are designed to be a more lightweight alternative to swapping out command sets when dynamic behavior on an
  object is required, but a more substantial change feels too heavy handed. There are a few special cases in which the
  engine will look for callbacks on an object, such as when an object is being puppeted/unpuppeted, or when commands
  are being processed.

  When a custom callback for an object has not been registered, a default implementation must be used instead. These can
  be specified by passing an atom to be used as a key to check the config, which is how the engine behaves for its
  internal hooks, or by passing a module name to be called directly. Default implementations have been provided for all
  engine hooks. This logic can be applied in application code as well when writing scripts and commands.
  """

  @doc """
  A callback module is an arbitrary hook to enable the insertion of custom logic into the processing flow of a command
  or script.
  """
  @callback execute(term) :: term

  alias Exmud.Cache
  alias Exmud.Object
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
  When running a callback, the engine first checks to see if there is an object specific implementation before falling
  back to a default implementation. If no default implementation is found an error is returned.
  """
  def run(object, key, args) do
    case Object.get_callback(object, key) do
      {:ok, callback} ->
        callback.callback_module.run(object, args)
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
  def register(key, callback_module) do
    Logger.debug("Registering callback for key `#{key}` with module `#{inspect(callback_module)}`")
    Cache.put(key, @callback_category, callback_module)
  end

  @doc """
  Check to see if there is a callback module registered with a given key.
  """
  def registered?(key) do
    Cache.exists?(key, @callback_category)
  end

  @doc """
  Return the module that has been registered with a given key.
  """
  def which_module(key) do
    Logger.debug("Finding callback module for key `#{key}`")
    case Cache.get(key, @callback_category) do
      {:error, _} ->
        Logger.warn("Attempt to find callback module for key `#{key}` failed")
        {:error, :no_such_callback}
      result -> result
    end
  end

  @doc false
  def unregister(key) do
    Cache.delete(key, @callback_category)
  end
end
