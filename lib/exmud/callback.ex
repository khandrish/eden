defmodule Exmud.Callback do
  @moduledoc """
  An `Exmud.GameObject` can have an arbitrary number of callbacks associated with it.

  Callbacks are designed to be a more lightweight alternative to swapping out command sets when dynamic behavior on an
  object is required, but a more substantial change feels too heavy handed. There are a few special cases in which the
  engine will look for callbacks on an object, such as when an object is being puppeted/unpuppeted.

  When a custom callback for an object has not been registered the engine will search to see if there is a default
  implementation, which are provided by the engine to nsure that consistent behavior is followed. This logic can be
  applied in application code as well when writing scripts and commands.
  """

  @doc """
  A callback module is an arbitrary hook to enable the insertion of custom logic into the processing flow of a command
  or script.
  """
  @callback execute(term) :: term

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
  A callback can only be registered with a unique key. This is primarily useful for a universal default callback when
  nothing more specific can be found attached to a given object. An example of this might be a `before_puppet`
  default callback which is essentially a no-op, allowing for a custom callback which could interrupt the puppeting
  process by returning `false`.
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
