defmodule Eden.EntityManager do
  alias Eden.Repo
  alias Eden.Entity
  import Ecto.Query, only: [from: 2]

  @ec_data :entity_cache
  @ec_index :entity_component_index
  @ce_index :component_entity_index
  @cke_index :component_key_entity_index
  @eck_index :entity_component_key_index

  def create_entity() do
    Ecto.UUID.generate
  end

  def get(id, component, key) do
    [{{_, _, _}, value}] = :ets.lookup(@ec_data, {id, component, key})
    value
  end

  def set(id, component, key, value) do
    if has_component?(id, component) do
      :ets.insert(@ec_data, {{id, component, key}, value})
      :ets.insert(@eck_index, {{id, component}, key})
      :ets.insert(@cke_index, {{component, key}, id})
    else
      :false
    end
  end

  def has_key?(id, component, key) do
    if length(:ets.match_object(@eck_index, {{id, component}, key})) == 1 do
      :true
    else
      :false
    end
  end

  def delete(id, component, key) do
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
    Enum.each(:ets.lookup(@eck_index, {id, component}), fn({{id, component}, key}) ->
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

  def delete_entity(id) do
    stream = :ets.lookup(@ec_index, id)
    |> Stream.each(fn({_, component}) -> :ets.delete_object(@ec_index, {id, component}); component end)
    |> Stream.each(fn(component) -> :ets.delete_object(@ce_index, {component, id}); component end)
    |> Stream.each(fn(component) -> :ets.lookup(@eck_index, {id, component}) end)
    |> Stream.each(fn({{_, component}, key}) -> {id, component, key} end)
    |> Stream.each(fn({_, component, k} = key) -> :ets.delete_object(@eck_index,  {{id, component}, k}); key end)
    |> Stream.each(fn({_, component, k} = key) -> :ets.delete_object(@cke_index, {{component, k}, id}); key end)
    |> Stream.each(fn(key) -> :ets.delete(@ec_data, key); key end)
    |> Stream.run
    :ok
  end

  def get_all_components(id) do
    for {_id, component} <- :ets.lookup(@ec_index, id), do: component
  end

  def load_all_entities do
    Repo.all(Entity)
    |> Stream.each(fn(entity) ->
        id = entity.id
        components = :erlang.binary_to_term(entity.components)
        Enum.each(components, fn({component, pairs}) ->
          :ets.insert_new(@ec_index, {id, component})
          :ets.insert_new(@ce_index, {component, id})
          Enum.each(pairs, fn({key, value}) ->
            :ets.insert_new(@eck_index, {{id, component}, key})
            :ets.insert_new(@cke_index, {{component, key}, id})
            :ets.insert_new(@ec_data,  {{id, component, key}, :erlang.binary_to_term(value)})
          end)
        end)
      end)
    |> Stream.run
  end

  def save_all_entities do
    #iterate_over_entity_cache_and_save(:ets.first(@ec_data))
    :ok
  end

  def empty_all_caches do
    :ets.delete_all_objects(@ec_data)
    :ets.delete_all_objects(@ec_index)
    :ets.delete_all_objects(@ce_index)
    :ets.delete_all_objects(@cke_index)
    :ets.delete_all_objects(@eck_index)
  end

  def persist_entity(id) do
    components = Enum.map(:ets.lookup(@ec_index, id), fn({_, component}) -> component end)
    component_map = Enum.reduce(components, %{}, fn(component, components) -> Map.put(components, component, %{}) end)
    component_map = Enum.reduce(components, component_map, fn(component, mapping) ->
      pairs = Enum.reduce(:ets.lookup(@eck_index, {id, component}), %{}, fn({{_, _}, key}, pairs) ->
        [{{_, _, _}, value}] = :ets.lookup(@ec_data, {id, component, key})
        Map.put(pairs, key, value)
      end)
      Map.put(mapping, component, pairs)
    end)

    Repo.insert! %Entity{id: id, components: :erlang.term_to_binary(component_map)}
    :true
  end

  def purge_entity(id) do
    delete_entity(id)
    Repo.delete! %Entity{id: id}
  end

  #
  # Private Functions
  #

  #defp iterate_over_entity_cache_and_save(:"$end_of_table") do
  #  :ok
  #end

  #defp iterate_over_entity_cache_and_save(key) do
  #  [{{id, component, key}, value}] = :ets.lookup(@ec_data, key)
  #  Repo.insert! Entity.changeset(%Entity{}, %{id: id,
  #                           components: components})
  #  iterate_over_entity_cache_and_save(:ets.next(@ec_data, key))
  #end
end