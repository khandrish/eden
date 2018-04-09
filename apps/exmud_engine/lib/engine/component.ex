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
  alias Exmud.Engine.Repo
  alias Exmud.Engine.Schema.Component
  import Ecto.Query
  import Exmud.Common.Utils
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
      def populate(_object_id), do: :ok

      defoverridable [name: 0,
                      populate: 1]
    end
  end

  @doc """
  The unique name of the Component.

  This unique string is used for registration in the Engine, and can be used to attach/detach Components.
  """
  @callback name :: String.t

  @doc """
  Called when a Component has been added to an Object. Is responsible for populating the Component with the necessary
  data.
  """
  @callback populate(object_id) :: :ok | {:error, error}

  @typedoc "An error message."
  @type error :: term

  @typedoc "The Object being populated with the Component and its data."
  @type object_id :: integer


  #
  # API
  #


  @doc """
  Attach one or more Components to an Object.

  Using a transaction, attach one or more Components and call their populate methods. This means a single error in a
  single Component will fail the whole operation.
  """
  def attach(object_id, components) do
    components =
      List.wrap(components)
      |> Enum.map(fn(component) ->
        case lookup(component) do
          {:ok, component} -> {:ok, component}
          error -> error
        end
      end)

    if Enum.all?(components, &(elem(&1, 0) == :ok)) do
      components = Enum.map(components, &(elem(&1, 1)))
      try do
        execute_attach(object_id, components)
      rescue
        error in Postgrex.Error ->
          if error.postgres.code == :unique_violation do
            {:error, :duplicate_component}
          else
            raise error
          end
      end
    else
      Enum.find(components, &(elem(&1, 0) == :error))
    end
  end

  defp execute_attach(object_id, components) do
    Repo.transaction(fn ->
      case attach_components(object_id, components) do
        {:ok, _result} ->
          Logger.info("Successfully added Components `#{Enum.map(components, &(&1.name()))}` to Object `#{object_id}`")
          :ok
        {:error, error} ->
          Logger.error("Failed to add Components `#{Enum.map(components, &(&1.name()))}` to Object `#{object_id}` because `#{error}`")
          Repo.rollback(error)
      end
    end)
    |> case do
      {:ok, _} -> :ok
      error -> error
    end
  end

  defp attach_components(object_id, components) do
    with :ok <- insert_components(object_id, components),
      do: populate_components(object_id, components)
  end

  defp insert_components(object_id, components) do
    args =
      components
      |> Enum.map(fn component ->
        %{name: component.name(),
          object_id: object_id}
      end)

    {count, _} = Repo.insert_all(Component, args)

    if count == length(components) do
      :ok
    else
      {:error, :component_insertion_failed}
    end
  end

  defp populate_components(object_id, components) do
    components
    |> Enum.map(&(&1.populate(object_id)))
    |> Enum.all?(fn(:ok) -> true; (_) -> false end)
    |> if do
      {:ok, object_id}
    else
      {:error, :component_population_failed}
    end
  end

  @doc """
  Retrieve a list of Components that match the provided name or belong to the provided Object id's from the optionally
  mixed list.

  All Attributes will be preloaded.
  """
  def get(names_or_object_ids) when is_list(names_or_object_ids) == false do
    {:ok, results} =
      names_or_object_ids
      |> List.wrap()
      |> get()

    {:ok, List.first(results)}
  end

  def get(names_or_object_ids) do
    {ids, names} = Enum.split_with(names_or_object_ids, &Kernel.is_integer/1)

    query =
      from component in Component,
        join: attribute in assoc(component, :attributes),
        where: component.name in ^names or component.object_id in ^ids,
        preload: [attributes: attribute]

    result =
      case Repo.all(query) do
        [] -> []
        names ->
          Enum.map(names, &normalize/1)
      end
    {:ok, result}
  end

  @doc """
  Retrieve a single of Component that matches the provided name and Object id.

  Note that all Attributes will be preloaded.
  """
  def get(object_id, name) do
    query =
      from component in Component,
        where: component.name == ^name
          and component.object_id == ^object_id,
        preload: :attributes

    component = Repo.one(query)

    case component do
      nil ->
        {:error, :no_such_component}
      component ->
        {:ok, normalize(component)}
    end
  end

  defp normalize(component) do
    attributes =
      Enum.map(component.attributes, fn(attribute) ->
        %{attribute | data: deserialize(attribute.data)}
      end)

    %{component | attributes: attributes}
  end

  @doc """
  Check to see if a given Component, or list of components, is attached to an Object. Will only return `true` if all
  provided values are matched.
  """
  def all_attached?(object_id, names) do
    names = List.wrap(names)

    query =
      from component in Component,
        where: component.object_id == ^object_id and component.name in ^names,
        select: count("*")

    if Repo.one(query) == length(names) do
      true
    else
      false
    end
  end

  @doc """
  Check to see if a given Component, or list of components, is attached to an Object. Will return `true` if any of the
  provided values are matched.
  """
  def any_attached?(object_id, names) do
    names = List.wrap(names)

    query =
      from component in Component,
        where: component.object_id == ^object_id and component.name in ^names,
        select: count("*")

    if Repo.one(query) >= length(names) do
      true
    else
      false
    end
  end

  @doc """
  Detach all Components, deleting all associated data, attached to a given Object.
  """
  def detach(object_ids) do
    delete_query =
      from component in Component,
        where: component.object_id in ^List.wrap(object_ids)

    Repo.delete_all(delete_query)

    :ok
  end

  @doc """
  Detach one or more Components, deleting all associated data, attached to a given Object.
  """
  def detach(object_id, names) do
    names = List.wrap(names)

    delete_query =
      from component in Component,
        where: component.name in ^names and component.object_id == ^object_id

    Repo.delete_all(delete_query)

    :ok
  end


  #
  # Manipulation of Components in the Engine.
  #

  @cache :component_cache

  @doc """
  List all Components registered with the Engine.
  """
  def list_registered() do
    Logger.info("Listing all registered Components")
    Cache.list(@cache)
  end

  @doc """
  Lookup a Component callback module based on the name it was registered with.
  """
  def lookup(name) do
    case Cache.get(@cache, name) do
      {:error, _} ->
        Logger.error("Lookup failed for Component registered with name `#{name}`")
        {:error, :no_such_component}
      result ->
        Logger.info("Lookup succeeded for Component registered with name `#{name}`")
        result
    end
  end

  @doc """
  Register a Component callback module with the Engine. Uses the value provided by the `name/0` function as the key.
  """
  def register(callback_module) do
    Logger.info("Registering Component with name `#{callback_module.name}` and module `#{inspect(callback_module)}`")
    case Cache.set(@cache, callback_module.name(), callback_module) do
      {:ok, _} -> {:ok, :registered}
      error -> error
    end
  end

  @doc """
  Check to see if a Component callback module is registered with the Engine.
  """
  def registered?(callback_module) do
    Logger.info("Checking registration of Component with name `#{callback_module.name()}`")
    Cache.exists?(@cache, callback_module.name())
  end

  @doc """
  Unregister a Component callback module is registered from the Engine.
  """
  def unregister(callback_module) do
    Logger.info("Unregistering Component with name `#{callback_module.name()}`")
    Cache.delete(@cache, callback_module.name())
  end
end