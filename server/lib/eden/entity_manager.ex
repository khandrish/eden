defmodule Eden.EntityManager do
  alias Eden.Repo
  alias Eden.Entity
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

  def get_key(id, component, key) do
    [{_, value}] = :ets.lookup(@ec_data, {id, component, key})
    value
  end

  def put_key(id, component, key, value) do
    :ets.insert(@ec_data, {{id, component, key}, value})
    :ets.insert(@eck_index, {{id, component}, key})
    :ets.insert(@cke_index, {{component, key}, id})
  end

  def has_key?(id, component, key) do
    if length(:ets.match_object(@eck_index, {{id, component}, key})) == 1 do
      :true
    else
      :false
    end
  end

  def delete_key(id, component, key) do
    :ets.delete(@ec_data, {id, component, key})
    :ets.delete_object(@eck_index, {{id, component}, key})
    :ets.delete_object(@cke_index, {{component, key}, id})
  end

  def add_component(id, component) do
    :ets.insert(@ec_index, {id, component})
    :ets.insert(@ce_index, {component, id})
  end

  def remove_component(id, component) do
    :ets.delete_object(@ec_index, {id, component})
    :ets.delete_object(@ce_index, {component, id})
    Enum.each(:ets.lookup(@eck_index, {id, component}), fn({_, key}) ->
      :ets.delete(@ec_data, {id, component, key})
      :ets.delete_object(@cke_index, {{component, key}, id})
    end)
    :ets.delete(@eck_index, {id, component})
  end

  def has_component?(id, component) do
    if length(:ets.match_object(@ec_index, {id, component})) == 1 do
      :true
    else
      :false
    end
  end

  def delete_entity_from_cache(id) do
    :ets.lookup(@ec_index, id)
    |> Enum.each(fn({_, component}) ->
      :ets.delete_object(@ec_index, {id, component})
      :ets.delete_object(@ce_index, {component, id})
      Enum.each(:ets.lookup(@eck_index, {id, component}), fn({_, key}) ->
        :ets.delete_object(@eck_index,  {{id, component}, key})
        :ets.delete_object(@cke_index, {{component, key}, id})
        :ets.delete_object(@ec_data, {{id, component}, key})
      end)
    end)
    :true
  end

  def delete_entity_from_db(id) do
    Repo.delete! %Entity{id: id}
    :true
  end

  def get_all_components(id) do
    for {_, component} <- :ets.lookup(@ec_index, id), do: component
  end

  def load_all_entities do
    Repo.all(Entity)
    |> unpack_entities
  end

  def load_entity(id) do
    query = from e in Entity,
            where: e.id == ^id
    query
    |> Repo.all
    |> unpack_entities
    :true
  end

  def persist_entity(id) do
    components = get_all_components(id)
    component_map = Enum.reduce(components, %{}, fn(component, components) -> Map.put(components, component, %{}) end)
    component_map = Enum.reduce(components, component_map, fn(component, mapping) ->
      pairs = Enum.reduce(:ets.lookup(@eck_index, {id, component}), %{}, fn({_, key}, pairs) ->
        [{_, value}] = :ets.lookup(@ec_data, {id, component, key})
        Map.put(pairs, key, value)
      end)
      Map.put(mapping, component, pairs)
    end)

    Repo.insert! %Entity{id: id, components: :erlang.term_to_binary(component_map)}
    :true
  end

  #
  # Private Functions
  #

  defp unpack_entities(entities) do
    Enum.each(entities, fn(entity) ->
      id = entity.id
      :erlang.binary_to_term(entity.components)
      |> Enum.each(fn({component, pairs}) ->
        :ets.insert_new(@ec_index, {id, component})
        :ets.insert_new(@ce_index, {component, id})
        Enum.each(pairs, fn({key, value}) ->
          :ets.insert_new(@eck_index, {{id, component}, key})
          :ets.insert_new(@cke_index, {{component, key}, id})
          :ets.insert_new(@ec_data,  {{id, component, key}, value})
        end)
      end)
    end)
  end
end