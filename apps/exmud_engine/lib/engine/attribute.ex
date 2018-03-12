defmodule Exmud.Engine.Attribute do
  @moduledoc """
  An `Exmud.Component` can have an arbitrary number of attributes associated with it.

  Attributes are where all of the actual data within the engine is stored, and all Attributes belong to a Component
  which has been attached to an Object.
  """

  alias Exmud.Engine.Component
  alias Exmud.Engine.Repo
  alias Exmud.Engine.Schema.Attribute
  import Ecto.Query
  import Exmud.Common.Utils
  require Logger


  #
  # API
  #


  def add(object_id, component, attribute, data) do
    case Component.get(object_id, component) do
      {:ok, comp} ->
        args = %{data: serialize(data),
                 attribute: attribute}

        Ecto.build_assoc(comp, :attributes, args)
        |> Repo.insert()
        |> normalize_repo_result(object_id)
      error ->
        error
    end
  end

  def equals(object_id, component, attribute, data) do
    query =
      from attribute in attribute_query(object_id, component, attribute),
        where: attribute.data == ^serialize(data)

    case Repo.one(query) do
      nil ->
        {:ok, false}
      _result ->
        {:ok, true}
    end
  end

  def get(object_id, component, attribute) do
    case Repo.one(attribute_query(object_id, component, attribute)) do
      nil -> {:error, :no_such_attribute}
      component_data -> {:ok, deserialize(component_data.data)}
    end
  end

  def has(object_id, component, attribute) do
    case Repo.one(attribute_query(object_id, component, attribute)) do
      nil -> {:ok, false}
      _object -> {:ok, true}
    end
  end

  def remove(object_id, component, attribute) do
    attribute_query(object_id, component, attribute)
    |> Repo.delete_all()
    |> case do
      {1, _} -> {:ok, object_id}
      {0, _} -> {:error, :no_such_attribute}
      _ -> {:error, :unknown}
    end
  end

  def update(object_id, component, attribute, data) do
    query =
      from attribute in attribute_query(object_id, component, attribute),
        update: [set: [data: ^serialize(data)]]

    case Repo.update_all(query, []) do
      {1, _} -> {:ok, object_id}
      {0, _} -> {:error, :no_such_attribute}
    end
  end


  #
  # Private functions
  #


  defp attribute_query(object_id, component_name, attribute) do
    from attribute in Attribute,
      inner_join: component in assoc(attribute, :component),
      where: attribute.attribute == ^attribute
        and component.name == ^component_name
        and component.object_id == ^object_id
  end
end