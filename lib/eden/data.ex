defmodule Eden.Data do
  @moduledoc """
  Provides abstraction and wrapping for the logic to get data from the database.
  """

  alias Amnesia.Selection
  alias Apex.Format, as: Ap
  alias Eden.Database.EntityComponent, as: EC
  alias Eden.Entity
  require Logger
  use Amnesia
  use Eden.Database
  use Timex

  #
  # API
  #

  # Entity level manipulation

  def new_entity do
    entity = EC.write(%EC{component: "entity", data: %{"created" => Timex.now}})
    %Entity{id: entity.id, components: %{entity.component => entity.data}}
  end

  def get_entity(id) do
    case EC.read(id) do
      nil -> nil
      entity_data ->
        entity = Enum.reduce(entity_data, %{}, &(deserialize(&1, &2)))
        [{id, components}] = Map.to_list(entity)
        %Entity{id: id, components: components}
    end
  end

  def get_entities_with_component(required_component) do
    values = Selection.values(EC.where(component == required_component))
    deserialize_entity_entries(values)
  end

  def get_entities_with_components([required_component|rest]) do
    deserialize_entity_entries(EC.match([component: "entity2"]))
  end

  # Component level manipulation

  def add_component(entity, component) do
    add_component(entity, component, %{})
  end

  def add_component(entity, component, data) do
    EC.write(%EC{id: entity, component: component, data: data})
  end

  def remove_component(entity, component) do
    
  end

  #
  # Private helper functions
  #
  defp deserialize_entity_entries(nil), do: []
  defp deserialize_entity_entries(entries) do
    entries
      |> Enum.reduce(%{}, &(deserialize(&1, &2)))
      |> Map.to_list
      |> Enum.reduce([], &([%Entity{id: elem(&1, 0), components: elem(&1, 1)}]  ++ &2))
  end

  defp deserialize(entity_record, entities) do
    component = entity_record.component
    data = entity_record.data

    initial_value = %{component => data}
    update_function = &(Map.put(&1, component, data))

    Map.update(entities, entity_record.id, initial_value, update_function)
  end

  # get_key
  # put_key
  # update_key
  # add_key
  # has_key
  # delete_key
  # 
  # 
end