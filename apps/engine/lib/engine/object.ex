defmodule Exmud.Engine.Object do
  alias Exmud.Engine.Repo
  alias Exmud.Engine.Schema.Object
  import Ecto.Query
  import Exmud.Common.Utils
  require Logger

  @get_inclusion_filters [:command_sets, :components, :locks, :links, :scripts, :tags]

  defstruct command_sets: MapSet.new(),
            components: MapSet.new(),
            locks: MapSet.new(),
            links: MapSet.new(),
            scripts: MapSet.new(),
            tags: MapSet.new(),
            relationships: MapSet.new()

  #
  # Typespecs
  #

  @typedoc """
  The id of an Object on which all operations are to take place.
  """
  @type object_id :: integer

  @typedoc """
  The Object is the basic building block of the Engine. Almost all data in the Engine is contained in an Object.
  """
  @type object :: term

  @typedoc """
  An error which happened during an operation.
  """
  @type error :: term

  @typedoc """
  Filters for specifing which data on an Object to load
  """
  @type inclusion_filters :: [
          :command_sets | :components | :locks | :links | :scripts | :tags
        ]

  @typedoc """
  A query to be used for finding populations of Objects.
  """
  @type object_query :: term

  #
  # API
  #

  @doc """
  Create a new Object.
  """
  @spec new! :: object_id
  def new! do
    %Object{date_created: DateTime.truncate(DateTime.utc_now(), :second)}
    |> Repo.insert!()
    |> (& &1.id).()
  end

  @doc """
  Delete an Object by its id.
  """
  @spec delete(object_id) :: :ok | {:error, :no_such_object}
  def delete(object_id) do
    query = from(object in Object, where: object.id == ^object_id)

    query
    |> Repo.delete_all()
    |> case do
      {1, _} -> :ok
      {0, _} -> {:error, :no_such_object}
    end
  end

  @doc """
  Get an Object, or multiple objects, by its id.

  Will load all of the data associated with an Object.
  """
  @spec get(object_id) :: {:ok, [object]}
  def get(objects) do
    get(objects, @get_inclusion_filters)
  end

  @doc """
  Get an Object, or multiple objects, by its id while specifying the inclusion filters.

  Inclusion filters allow specifying which data will be preloaded on the Object being returned.

  Can be any of the following:
  `[:command_sets, :components, :locks, :links, :scripts, :tags]`
  """
  @spec get(object_id, inclusion_filters) :: {:ok, [object]}
  def get(object, inclusion_filters) when is_list(object) == false do
    {:ok, results} = get(List.wrap(object), inclusion_filters)
    {:ok, List.first(results)}
  end

  def get(object_ids, inclusion_filters) do
    object_ids = List.wrap(object_ids)

    base_query = from(object in Object, where: object.id in ^object_ids)

    inclusion_filters = List.wrap(inclusion_filters)

    query = build_get_query(base_query, inclusion_filters)

    results =
      Repo.all(query)
      |> normalize_get_results(inclusion_filters)

    {:ok, results}
  end

  @doc """
  Query the Engine for Objects based on the passed in query.

  The query is a custom syntax which allows for an arbitary combination and nesting of equality checks. Currently, only
  equality checks are supported. This is unlikely to change without a refactoring as data is pack_termd in the database
  which makes doing relative value checks impossible.
  """
  @spec query(object_query) :: {:ok, [object]}
  def query(object_query) do
    result =
      object_query
      |> build_object_query()
      |> Repo.all()

    {:ok, result}
  end

  #
  # Private functions
  #

  # Query functions

  defp build_object_query(object_query) do
    dynamic = build_where(object_query)

    from(
      object in Object,
      left_join: command_set in assoc(object, :command_sets),
      left_join: component in assoc(object, :components),
      left_join: attribute in assoc(component, :attributes),
      left_join: link in assoc(object, :links),
      left_join: tag in assoc(object, :tags),
      select: object.id,
      where: ^dynamic
    )
  end

  defp build_where({mode, checks}) do
    actually_build_where(nil, mode, checks)
  end

  defp actually_build_where(dynamic, _, []), do: dynamic

  defp actually_build_where(dynamic, mode, [{type, nested_checks} | checks])
       when type == :and or type == :or do
    new_dynamic = actually_build_where(nil, type, nested_checks)

    dynamic =
      case mode do
        :and -> dynamic(^dynamic and ^new_dynamic)
        :or -> dynamic(^dynamic or ^new_dynamic)
      end

    actually_build_where(dynamic, mode, checks)
  end

  defp actually_build_where(dynamic, mode, [check | checks]) do
    new_dynamic = build_equality_check_dynamic(check)

    if dynamic != nil do
      dynamic =
        case mode do
          :and -> dynamic([], ^new_dynamic and ^dynamic)
          :or -> dynamic([], ^new_dynamic or ^dynamic)
        end

      actually_build_where(dynamic, mode, checks)
    else
      actually_build_where(new_dynamic, mode, checks)
    end
  end

  defp build_equality_check_dynamic({:attribute, {component, attribute_name}}) do
    dynamic(
      [object, command_set, component, attribute],
      attribute.name == ^attribute_name and component.callback_module == ^pack_term(component)
    )
  end

  defp build_equality_check_dynamic({:attribute, {component, attribute_name, attribute_value}}) do
    dynamic(
      [object, command_set, component, attribute],
      attribute.name == ^attribute_name and
        component.callback_module == ^pack_term(component) and
        attribute.value == ^pack_term(attribute_value)
    )
  end

  defp build_equality_check_dynamic({:command_set, command_set}) do
    dynamic([object, command_set], command_set.callback_module == ^pack_term(command_set))
  end

  defp build_equality_check_dynamic({:component, component}) do
    dynamic([object, command_set, component], component.callback_module == ^pack_term(component))
  end

  defp build_equality_check_dynamic({:link, {link_type, {:to, to}, state}}) do
    dynamic(
      [object, command_set, component, attribute, link],
      link.type == ^link_type and link.to_id == ^to and link.state == ^pack_term(state)
    )
  end

  defp build_equality_check_dynamic({:link, {link_type, {:from, from}, state}}) do
    dynamic(
      [object, command_set, component, attribute, link],
      link.type == ^link_type and link.from_id == ^from and link.state == ^pack_term(state)
    )
  end

  defp build_equality_check_dynamic({:link, {link_type, {:to, to}}}) do
    dynamic(
      [object, command_set, component, attribute, link],
      link.type == ^link_type and link.to_id == ^to
    )
  end

  defp build_equality_check_dynamic({:link, {link_type, {:from, from}}}) do
    dynamic(
      [object, command_set, component, attribute, link],
      link.type == ^link_type and link.from_id == ^from
    )
  end

  defp build_equality_check_dynamic({:link, link_type}) do
    dynamic([object, command_set, component, attribute, link], link.type == ^link_type)
  end

  defp build_equality_check_dynamic({:tag, {category, tag}}) do
    dynamic(
      [object, command_set, component, attribute, link, tag],
      tag.category == ^category and tag.tag == ^tag
    )
  end

  # Get Query

  defp build_get_query(query, []), do: query

  defp build_get_query(query, [:command_sets | inclusion_filters]) do
    query =
      from(
        object in query,
        left_join: command_set in assoc(object, :command_sets),
        preload: [:command_sets]
      )

    build_get_query(query, inclusion_filters)
  end

  defp build_get_query(query, [:components | inclusion_filters]) do
    query =
      from(
        object in query,
        left_join: component in assoc(object, :components),
        left_join: attribute in assoc(component, :attributes),
        preload: [components: {component, attributes: attribute}]
      )

    build_get_query(query, inclusion_filters)
  end

  defp build_get_query(query, [:locks | inclusion_filters]) do
    query =
      from(
        object in query,
        left_join: lock in assoc(object, :locks),
        preload: [:locks]
      )

    build_get_query(query, inclusion_filters)
  end

  defp build_get_query(query, [:links | inclusion_filters]) do
    query =
      from(
        object in query,
        left_join: link in assoc(object, :links),
        preload: [:links]
      )

    build_get_query(query, inclusion_filters)
  end

  defp build_get_query(query, [:scripts | inclusion_filters]) do
    query =
      from(
        object in query,
        left_join: script in assoc(object, :scripts),
        preload: [:scripts]
      )

    build_get_query(query, inclusion_filters)
  end

  defp build_get_query(query, [:tags | inclusion_filters]) do
    query =
      from(
        object in query,
        left_join: tag in assoc(object, :tags),
        preload: [:tags]
      )

    build_get_query(query, inclusion_filters)
  end

  defp normalize_get_results(objects, [:components | rest]) do
    objects =
      Enum.map(objects, fn object ->
        %{
          object
          | components:
              Enum.map(object.components, fn component ->
                %{
                  component
                  | attributes:
                      Enum.map(component.attributes, fn attribute ->
                        %{attribute | value: unpack_term(attribute.value)}
                      end)
                }
              end)
        }
      end)

    normalize_get_results(objects, rest)
  end

  defp normalize_get_results(objects, [:command_sets | rest]) do
    objects =
      Enum.map(objects, fn object ->
        command_sets =
          Enum.map(object.command_sets, fn command_set ->
            %{command_set | callback_module: unpack_term(command_set.callback_module)}
          end)

        %{object | command_sets: command_sets}
      end)

    normalize_get_results(objects, rest)
  end

  defp normalize_get_results(objects, _), do: objects
end
