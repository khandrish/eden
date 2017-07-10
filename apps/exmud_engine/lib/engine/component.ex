defmodule Exmud.Engine.Component do
  alias Ecto.Multi
  alias Exmud.Engine.Repo
  alias Exmud.Engine.Schema.Component
  import Ecto.Query
  import Exmud.Common.Utils
  require Logger


  #
  # API
  #


  def add(object_id, components) do
    args =
      components
      |> List.wrap()
      |> Enum.map(fn component ->
        %{component: serialize(component),
          object_id: object_id}
      end)

    Repo.insert_all(Component, args)

    {:ok, object_id}
  end

  def add(%Ecto.Multi{} = multi, multi_key, object_id, component) do
    Multi.run(multi, multi_key, fn(_) ->
      add(object_id, component)
    end)
  end

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

  def get(%Ecto.Multi{} = multi, multi_key, components_or_object_ids) do
    Multi.run(multi, multi_key, fn(_) ->
      get(components_or_object_ids)
    end)
  end

  def get(object_id, component) do
    component =
      component_query(object_id, component)
      |> Repo.one()

    case component do
      nil ->
        {:error, :no_such_component}
      component ->
        {:ok, normalize(component)}
    end
  end

  def get(%Ecto.Multi{} = multi, multi_key, object_id, component) do
    Multi.run(multi, multi_key, fn(_) ->
      get(object_id, component)
    end)
  end

  def has(object_id, components) do
    components =
      components
      |> List.wrap()
      |> Enum.map(&serialize/1)

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

  def has(%Ecto.Multi{} = multi, multi_key, object_id, components) do
    Multi.run(multi, multi_key, fn(_) ->
      has(object_id, components)
    end)
  end

  def has_any(object_id, components) do
    components =
      components
      |> List.wrap()
      |> Enum.map(&serialize/1)

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

  def has_any(%Ecto.Multi{} = multi, multi_key, object_id, components) do
    Multi.run(multi, multi_key, fn(_) ->
      has_any(object_id, components)
    end)
  end

  def remove(object_ids) do
    delete_query =
      from component in Component,
        where: component.object_id in ^List.wrap(object_ids)

    delete_query
    |> Repo.delete_all()
    |> normalize_repo_result(true)
  end

  def remove(object_id, components) do
    components =
      components
      |> List.wrap()
      |> Enum.map(&serialize/1)

    delete_query =
      from component in Component,
        where: component.component in ^components and component.object_id == ^object_id

    Repo.delete_all(delete_query)

    {:ok, true}
  end

  def remove(%Ecto.Multi{} = multi, multi_key, object_id, component) do
    Multi.run(multi, multi_key, fn(_) ->
      remove(object_id, component)
    end)
  end


  #
  # Private functions
  #


  defp component_query(object_id, component) do
    from component in Component,
      where: component.component == ^serialize(component)
        and component.object_id == ^object_id,
      preload: :attributes
  end

  defp normalize(component) do
    attributes =
      Enum.map(component.attributes, fn(attribute) ->
        %{attribute | data: deserialize(attribute.data)}
      end)

    %{component | attributes: attributes, component: deserialize(component.component)}
  end
end