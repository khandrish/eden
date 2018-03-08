defmodule Exmud.Engine.Object do
  alias Exmud.Engine.Repo
  alias Exmud.Engine.Schema.Object
  import Ecto.Query
  import Exmud.Common.Utils
  require Logger

  @get_inclusion_filters [:callbacks, :command_sets, :components, :locks, :relationships, :scripts, :tags]


  #
  # API
  #


  def new(key) do
    Object.new(%Object{}, %{key: key})
    |> Repo.insert()
    |> case do
      {:ok, object} -> {:ok, object.id}
      {:error, changeset} -> {:error, normalize_ecto_errors(changeset.errors)}
    end
  end

  def delete(object_id) do
    {:ok, _} = Repo.delete(%Object{id: object_id})
    {:ok, object_id}
  end

  def get(objects) do
    get(objects, @get_inclusion_filters)
  end

  def get(object, inclusion_filters) when is_list(object) == false do
    {:ok, results} = get(List.wrap(object), inclusion_filters)
    {:ok, List.first(results)}
  end

  def get(objects, inclusion_filters) do
    {ids, keys} = Enum.split_with(objects, &Kernel.is_integer/1)

    base_query =
      from object in Object,
        where: object.key in ^keys or object.id in ^ids

    inclusion_filters = List.wrap(inclusion_filters)

    query = build_get_query(base_query, inclusion_filters)

    results =
      Repo.all(query)
      |> normalize_get_results(inclusion_filters)

    {:ok, results}
  end

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

    from object in Object,
      left_join: callback in assoc(object, :callbacks),
      left_join: command_set in assoc(object, :command_sets),
      left_join: component in assoc(object, :components),
      left_join: attribute in assoc(component, :attributes),
      left_join: relationship in assoc(object, :relationships),
      left_join: tag in assoc(object, :tags),
      select: object.id,
      where: ^dynamic
  end

  defp build_where({mode, checks}) do
    actually_build_where(nil, mode, checks)
  end

  defp actually_build_where(dynamic, _, []), do: dynamic

  defp actually_build_where(dynamic, mode, [{type, nested_checks} | checks]) when type == :and or type == :or do
    new_dynamic = actually_build_where(nil, type, nested_checks)

    dynamic =
      case mode do
        :and -> dynamic(^dynamic and (^new_dynamic))
        :or -> dynamic(^dynamic or (^new_dynamic))
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

  defp build_equality_check_dynamic({:attribute, {component, attribute}}) do
    dynamic([object, callback, command_set, component, attribute], (attribute.attribute == ^attribute and component.component == ^component))
  end

  defp build_equality_check_dynamic({:callback, callback}) do
    dynamic([object, callback], callback.key == ^callback)
  end

  defp build_equality_check_dynamic({:command_set, command_set}) do
    dynamic([object, callback, command_set], command_set.command_set == ^serialize(command_set))
  end

  defp build_equality_check_dynamic({:component, component}) do
    dynamic([object, callback, command_set, component], component.component == ^component)
  end

  defp build_equality_check_dynamic({:object, key}) do
    dynamic([object], object.key == ^key)
  end

  defp build_equality_check_dynamic({:relationship, {relationship, to, data}}) do
    dynamic([object, callback, command_set, component, attribute, relationship], (relationship.relationship == ^relationship and relationship.to_id == ^to and relationship.data == ^serialize(data)))
  end

  defp build_equality_check_dynamic({:relationship, {relationship, to}}) do
    dynamic([object, callback, command_set, component, attribute, relationship], (relationship.relationship == ^relationship and relationship.to_id == ^to))
  end

  defp build_equality_check_dynamic({:relationship, relationship}) do
    dynamic([object, callback, command_set, component, attribute, relationship], relationship.relationship == ^relationship)
  end

  defp build_equality_check_dynamic({:tag, {category, tag}}) do
    dynamic([object, callback, command_set, component, attribute, relationship, tag],
            (tag.category == ^category and tag.tag == ^tag))
  end

  # Get Query

  defp build_get_query(query, []), do: query

  defp build_get_query(query, [:callbacks | inclusion_filters]) do
    query =
      from object in query,
        left_join: callback in assoc(object, :callbacks),
        preload: [:callbacks]

    build_get_query(query, inclusion_filters)
  end

  defp build_get_query(query, [:command_sets | inclusion_filters]) do
    query =
      from object in query,
        left_join: command_set in assoc(object, :command_sets),
        preload: [:command_sets]

    build_get_query(query, inclusion_filters)
  end

  defp build_get_query(query, [:components | inclusion_filters]) do
    query =
      from object in query,
        left_join: component in assoc(object, :components),
        left_join: attribute in assoc(component, :attributes),
        preload: [components: {component, attributes: attribute}]

    build_get_query(query, inclusion_filters)
  end

  defp build_get_query(query, [:locks | inclusion_filters]) do
    query =
      from object in query,
        left_join: lock in assoc(object, :locks),
        preload: [:locks]

    build_get_query(query, inclusion_filters)
  end

  defp build_get_query(query, [:relationships | inclusion_filters]) do
    query =
      from object in query,
        left_join: relationship in assoc(object, :relationships),
        preload: [:relationships]

    build_get_query(query, inclusion_filters)
  end

  defp build_get_query(query, [:scripts | inclusion_filters]) do
    query =
      from object in query,
        left_join: script in assoc(object, :scripts),
        preload: [:scripts]

    build_get_query(query, inclusion_filters)
  end

  defp build_get_query(query, [:tags | inclusion_filters]) do
    query =
      from object in query,
        left_join: tag in assoc(object, :tags),
        preload: [:tags]

    build_get_query(query, inclusion_filters)
  end

  defp normalize_get_results(objects, [:components | rest]) do
    objects =
      Enum.map(objects, fn(object) ->
        %{object | components: Enum.map(object.components, fn(component) ->
            %{component | attributes: Enum.map(component.attributes, fn(attribute) ->
              %{attribute | data: deserialize(attribute.data)}
            end)}
        end)}
      end)

    normalize_get_results(objects, rest)
  end

  defp normalize_get_results(objects, [:command_sets | rest]) do
    objects =
      Enum.map(objects, fn(object) ->
        command_sets =
          Enum.map(object.command_sets, fn(command_set) ->
            %{command_set | command_set: deserialize(command_set.command_set)}
          end)
        %{object | command_sets: command_sets}
      end)

    normalize_get_results(objects, rest)
  end

  defp normalize_get_results(objects, _), do: objects
end