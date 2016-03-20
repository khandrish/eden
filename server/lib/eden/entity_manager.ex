defmodule Eden.EntityManager do
  alias Eden.Repo
  alias Eden.Schema.Entity
  import Ecto.Query, only: [from: 2]

  @ec_data :entity_cache
  @ec_index :entity_component_index
  @ce_index :component_entity_index
  @cke_index :component_key_entity_index
  @eck_index :entity_component_key_index

  #
  # cache management
  #

  def create_caches() do
    options = [:named_table, :public]
    :ets.new(@ec_data, options)
    options = options ++ [:bag]
    :ets.new(@ce_index, options)
    :ets.new(@cke_index, options)
    :ets.new(@ec_index, options)
    :ets.new(@eck_index, options)
  end

  def delete_caches() do
    :ets.delete(@ec_data)
    :ets.delete(@ec_index)
    :ets.delete(@ce_index)
    :ets.delete(@cke_index)
    :ets.delete(@eck_index)
  end

  def empty_all_caches do
    :ets.delete_all_objects(@ec_data)
    :ets.delete_all_objects(@ec_index)
    :ets.delete_all_objects(@ce_index)
    :ets.delete_all_objects(@cke_index)
    :ets.delete_all_objects(@eck_index)
  end

  #
  # entity management
  #

  def create_entity() do
    Ecto.UUID.generate
  end

  def get_key(entity_id, component, key) do
    [{_, value}] = :ets.lookup(@ec_data, {entity_id, component, key})
    value
  end

  def put_key(entity_id, component, key, value) do
    :ets.insert(@ec_data, {{entity_id, component, key}, value})
    :ets.insert(@eck_index, {{entity_id, component}, key})
    :ets.insert(@cke_index, {{component, key}, entity_id})
  end

  def has_key?(entity_id, component, key) do
    if length(:ets.match_object(@eck_index, {{entity_id, component}, key})) == 1 do
      :true
    else
      :false
    end
  end

  def delete_key(entity_id, component, key) do
    :ets.delete(@ec_data, {entity_id, component, key})
    :ets.delete_object(@eck_index, {{entity_id, component}, key})
    :ets.delete_object(@cke_index, {{component, key}, entity_id})
  end

  def add_component(entity_id, component) do
    :ets.insert(@ec_index, {entity_id, component})
    :ets.insert(@ce_index, {component, entity_id})
  end

  def remove_component(entity_id, component) do
    :ets.delete_object(@ec_index, {entity_id, component})
    :ets.delete_object(@ce_index, {component, entity_id})
    Enum.each(:ets.lookup(@eck_index, {entity_id, component}), fn({_, key}) ->
      :ets.delete(@ec_data, {entity_id, component, key})
      :ets.delete_object(@cke_index, {{component, key}, entity_id})
    end)
    :ets.delete(@eck_index, {entity_id, component})
  end

  def has_component?(entity_id, component) do
    if length(:ets.match_object(@ec_index, {entity_id, component})) == 1 do
      :true
    else
      :false
    end
  end

  def delete_entity_from_cache(entity_id) do
    :ets.lookup(@ec_index, entity_id)
    |> Enum.each(fn({_, component}) ->
      :ets.delete_object(@ec_index, {entity_id, component})
      :ets.delete_object(@ce_index, {component, entity_id})
      Enum.each(:ets.lookup(@eck_index, {entity_id, component}), fn({_, key}) ->
        :ets.delete_object(@eck_index,  {{entity_id, component}, key})
        :ets.delete_object(@cke_index, {{component, key}, entity_id})
        :ets.delete_object(@ec_data, {{entity_id, component}, key})
      end)
    end)
    :true
  end

  def delete_entity_from_db(entity_id) do
    Repo.delete! %Entity{entity_id: entity_id}
    :true
  end

  def get_all_components(entity_id) do
    for {_, component} <- :ets.lookup(@ec_index, entity_id), do: component
  end

  def get_entities_with_component(component) do
    get_entities_with_components([component])
  end

  def get_entities_with_components(components) do
    [first_set|rest] = Enum.reduce(components, [], fn(component, sets) ->
      [(for entity <- :ets.lookup_element(@ce_index, component, 2), into: MapSet.new(), do: entity)|sets]
    end)

    Enum.reduce(rest, first_set, fn(test_set, control_set) ->
      MapSet.intersection(control_set, test_set)
    end)
    |> MapSet.to_list
  end

  def load_all_entities do
    Repo.all(Entity)
    |> unpack_entities
  end

  def load_entity(entity_id) do
    query = from e in Entity,
            where: e.entity_id == ^entity_id
    query
    |> Repo.all
    |> unpack_entities
    :true
  end

  def persist_entity(entity_id) do
    components = get_all_components(entity_id)
    component_map = Enum.reduce(components, %{}, fn(component, components) -> Map.put(components, component, %{}) end)
    component_map = Enum.reduce(components, component_map, fn(component, mapping) ->
      pairs = Enum.reduce(:ets.lookup(@eck_index, {entity_id, component}), %{}, fn({_, key}, pairs) ->
        [{_, value}] = :ets.lookup(@ec_data, {entity_id, component, key})
        Map.put(pairs, key, value)
      end)
      Map.put(mapping, component, pairs)
    end)

    Repo.insert! %Entity{entity_id: entity_id, components: :erlang.term_to_binary(component_map)}
    :true
  end

  #
  # Private Functions
  #

  defp unpack_entities(entities) do
    Enum.each(entities, fn(entity) ->
      entity_id = entity.entity_id
      :erlang.binary_to_term(entity.components)
      |> Enum.each(fn({component, pairs}) ->
        :ets.insert_new(@ec_index, {entity_id, component})
        :ets.insert_new(@ce_index, {component, entity_id})
        Enum.each(pairs, fn({key, value}) ->
          :ets.insert_new(@eck_index, {{entity_id, component}, key})
          :ets.insert_new(@cke_index, {{component, key}, entity_id})
          :ets.insert_new(@ec_data,  {{entity_id, component, key}, value})
        end)
      end)
    end)
  end
end
