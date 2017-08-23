defmodule Exmud.Engine.Component do
  @moduledoc """
  Components act both as flags, indicating that an Object has some set of properties, and as containers for attributes
  that are in some way related.

  For example, a character Component might hold information about the account it belongs to, relationships to other
  characters, aliases, skillpoints, and so on.

  Each Component added to an Object should be populated with the expected fields and values required for game logic to
  successfully interact with the Object. If there is zero data associated with a Component a Tag might be more
  appropriate.
  """


  #
  # Behavior definition and default callback setup
  #


  @doc """
  Called when a message has been sent to the System.
  """
  @callback populate(object_id, component) :: {:ok, :populated} | {:error, error}

  @typedoc "An error message passed through to the caller."
  @type error :: term

  @typedoc "The Object being populated with the Component and its data."
  @type object_id :: term

  @typedoc "The Component being populated with data."
  @type component :: String.t


  #
  # Component module
  #


  alias Exmud.Engine.Cache
  alias Exmud.Engine.Repo
  alias Exmud.Engine.Schema.Component
  import Ecto.Query
  import Exmud.Common.Utils
  require Logger


  #
  # Adding components to an object
  #


  def add(object_id, components) do
    Repo.transaction(fn ->
      case add_components(object_id, List.wrap(components)) do
        {:error, error} ->
          Logger.error("Failed to add Components `#{components}` to Object `#{object_id}` because `#{error}`")
          Repo.rollback(error)
        {:ok, result} ->
          Logger.info("Successfully added Components `#{components}` to Object `#{object_id}`")
          result
      end
    end)
  end

  defp add_components(object_id, components) do
    with :ok <- insert_components(object_id, components),
      do: populate_components(object_id, components)
  end

  defp insert_components(object_id, components) do
    args =
      components
      |> Enum.map(fn component ->
        %{component: component,
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
    |> Enum.map(fn(component) ->
      case lookup(component) do
        {:ok, callback} -> callback.populate()
        error -> error
      end
    end)
    |> Enum.all?(fn({:ok, :populated}) -> true; (_) -> false end)
    |> if do
      {:ok, object_id}
    else
      {:error, :component_population_failed}
    end
  end


  #
  # Get all components from a list of components, or all components from a list of object id's.
  #


  def get(components_or_object_ids) when is_list(components_or_object_ids) == false do
    {:ok, results} = components_or_object_ids
    |> List.wrap()
    |> get()

    {:ok, List.first(results)}
  end

  def get(components_or_object_ids) do
    {ids, components} = Enum.split_with(components_or_object_ids, &Kernel.is_integer/1)

    query =
      from component in Component,
        join: attribute in assoc(component, :attributes),
        where: component.component in ^components or component.object_id in ^ids,
        preload: [attributes: attribute]

    result =
      case Repo.all(query) do
        [] -> []
        components ->
          Enum.map(components, &normalize/1)
      end
    {:ok, result}
  end

  def get(object_id, component) do
    query =
      from component in Component,
        where: component.component == ^component
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


  #
  # Check presence of components on an Object.
  #


  def has(object_id, components) do
    components = List.wrap(components)

    query =
      from component in Component,
        where: component.object_id == ^object_id and component.component in ^components,
        select: count("*")

    result = Repo.one(query)

    if result == length(components) do
      {:ok, true}
    else
      {:ok, false}
    end
  end

  def has_any(object_id, components) do
    components = List.wrap(components)

    query =
      from component in Component,
        where: component.object_id == ^object_id and component.component in ^components,
        select: count("*")

    if Repo.one(query) > 0 do
      {:ok, true}
    else
      {:ok, false}
    end
  end


  #
  # Remove components from an Object.
  #


  def remove(object_ids) do
    delete_query =
      from component in Component,
        where: component.object_id in ^List.wrap(object_ids)

    Repo.delete_all(delete_query)

    {:ok, true}
  end

  def remove(object_id, components) do
    components = List.wrap(components)

    delete_query =
      from component in Component,
        where: component.component in ^components and component.object_id == ^object_id

    Repo.delete_all(delete_query)

    {:ok, true}
  end


  #
  # Manipulation of Components in the Engine.
  #

  @cache :component_cache

  def list_registered() do
    Logger.info("Listing all registered Components")
    Cache.list(@cache)
  end

  def lookup(key) do
    case Cache.get(@cache, key) do
      {:error, _} ->
        Logger.error("Lookup failed for Component registered with key `#{key}`")
        {:error, :no_such_component}
      result ->
        Logger.info("Lookup succeeded for Component registered with key `#{key}`")
        result
    end
  end

  def register(key, callback_module) do
    Logger.info("Registering Component with key `#{key}` and module `#{inspect(callback_module)}`")
    case Cache.set(@cache, key, callback_module) do
      {:ok, _} -> {:ok, :registered}
      error -> error
    end
  end

  def registered?(key) do
    Logger.info("Checking registration of Component with key `#{key}`")
    Cache.exists?(@cache, key)
  end

  def unregister(key) do
    Logger.info("Unregistering Component with key `#{key}`")
    Cache.delete(@cache, key)
  end
end