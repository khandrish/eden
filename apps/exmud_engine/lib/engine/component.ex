defmodule Exmud.Engine.Component do
  @moduledoc """
  Components act both as flags, indicating that an Object has some set of properties, and as containers for attributes
  that are in some way related. They complement Tags and should be used when a simple boolean value is not enough.

  For example, a character Component might hold information about the account it belongs to, relationships to other
  characters, aliases, skillpoints, and so on.

  Each Component added to an Object should be populated with the expected fields and values required for game logic to
  successfully interact with the Object. If there is zero data associated with a Component a Tag might be more
  appropriate.
  """

  alias Exmud.Engine.Cache
  alias Exmud.Engine.ObjectUtil
  alias Exmud.Engine.Repo
  alias Exmud.Engine.Schema.Component
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
      @behaviour Exmud.Engine.Component

      @doc false
      def name, do: Atom.to_string(__MODULE__)

      @doc false
      def populate(_object_id, _args), do: :ok

      defoverridable name: 0,
                     populate: 2
    end
  end

  @doc """
  The unique name of the Component.

  This unique string is used for registration in the Engine, and can be used to attach/detach Components.
  """
  @callback name :: String.t()

  @doc """
  The unique name of the Component.

  This unique string is used for registration in the Engine, and can be used to attach/detach Components.
  """
  @callback attributes :: [String.t()]

  @doc """
  Called when a Component has been added to an Object. Is responsible for populating the Component with the necessary
  data.
  """
  @callback populate(object_id, config) :: :ok | {:error, error}

  @typedoc "The Object being populated with the Component and its data."
  @type object_id :: integer

  @typedoc "Configuration passed through to a callback module."
  @type config :: term

  @typedoc "The name of the Component as registered with the Engine."
  @type component_name :: String.t()

  @typedoc "The name of an Attribute belonging to a Component."
  @type attribute :: String.t()

  @typedoc "An error returned when something has gone wrong."
  @type error :: atom

  @typedoc "The callback_module that is the implementation of the Component logic."
  @type callback_module :: atom

  #
  # API
  #

  @doc """
  Atomically attach a Component to an Object and populate it with attributes using the provided, optional, args.
  """
  @spec attach(object_id, component_name, config | nil) ::
          :ok | {:error, :no_such_object} | {:error, :already_attached} | {:error, error}
  def attach(object_id, component_name, config \\ nil) do
    with {:ok, callback_module} <- lookup(component_name) do
      record = Component.new(%{name: component_name, object_id: object_id})
      ObjectUtil.attach(record, fn -> callback_module.populate(object_id, config) end)
    end
  end

  @doc """
  Check to see if a given Component, or list of components, is attached to an Object. Will only return `true` if all
  provided values are matched.
  """
  @spec all_attached?(object_id, component_name | [component_name]) :: boolean
  def all_attached?(object_id, component_names) do
    component_names = List.wrap(component_names)

    query = count_query(object_id, component_names)

    Repo.one(query) == length(component_names)
  end

  @doc """
  Check to see if a given Component, or list of components, is attached to an Object. Will return `true` if any of the
  provided values are matched.
  """
  @spec any_attached?(object_id, component_name | [component_name]) :: boolean
  def any_attached?(object_id, component_names) do
    component_names = List.wrap(component_names)

    query = count_query(object_id, component_names)

    Repo.one(query) >= length(component_names)
  end

  @doc """
  Detach all Components, deleting all associated data, attached to a given Object or set of Objects.
  """
  @spec detach(object_id | [object_id]) :: :ok
  def detach(object_ids) do
    delete_query =
      from(component in Component, where: component.object_id in ^List.wrap(object_ids))

    Repo.delete_all(delete_query)

    :ok
  end

  @doc """
  Detach one or more Components, deleting all associated data, attached to a given Object.
  """
  @spec detach(object_id, component_name | [component_name]) :: :ok
  def detach(object_id, component_names) do
    component_names = List.wrap(component_names)

    delete_query = component_query(object_id, component_names)

    Repo.delete_all(delete_query)

    :ok
  end

  @spec detach(object_id, [component_name]) :: term
  defp component_query(object_id, component_names) do
    from(
      component in Component,
      where: component.name in ^component_names and component.object_id == ^object_id
    )
  end

  @spec count_query(object_id, [component_name]) :: term
  defp count_query(object_id, component_names) do
    from(
      component in Component,
      where: component.name in ^component_names and component.object_id == ^object_id,
      select: count("*")
    )
  end

  #
  # Manipulation of Components in the Engine.
  #

  @cache :component_cache

  @doc """
  List all Components registered with the Engine.
  """
  @spec list_registered :: [callback_module]
  def list_registered do
    Logger.info("Listing all registered Components")
    Cache.list(@cache)
  end

  @doc """
  Lookup a Component callback module based on the name it was registered with.
  """
  @spec lookup(component_name) :: {:ok, callback_module} | {:error, :no_such_component}
  def lookup(component_name) do
    case Cache.get(@cache, component_name) do
      {:error, _} ->
        Logger.error("Lookup failed for Component registered with name `#{component_name}`")
        {:error, :no_such_component}

      result ->
        Logger.info("Lookup succeeded for Component registered with name `#{component_name}`")
        result
    end
  end

  @doc """
  Register a Component callback module with the Engine. Uses the value provided by the `name/0` function as the key.
  """
  @spec register(callback_module) :: :ok
  def register(callback_module) do
    Logger.info(
      "Registering Component with name `#{callback_module.name}` and module `#{
        inspect(callback_module)
      }`"
    )

    Cache.set(@cache, callback_module.name(), callback_module)
  end

  @doc """
  Check to see if a Component callback module is registered with the Engine.
  """
  @spec registered?(callback_module) :: boolean
  def registered?(callback_module) do
    Logger.info("Checking registration of Component with name `#{callback_module.name()}`")
    Cache.exists?(@cache, callback_module.name())
  end

  @doc """
  Unregister a Component callback module is registered from the Engine.
  """
  @spec unregister(callback_module) :: :ok
  def unregister(callback_module) do
    Logger.info("Unregistering Component with name `#{callback_module.name()}`")
    Cache.delete(@cache, callback_module.name())
  end
end
