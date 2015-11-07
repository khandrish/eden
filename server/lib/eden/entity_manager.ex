defmodule Eden.EntityManager do
  alias Eden.Repo
  alias Eden.Entity
  import Ecto.Query, only: [from: 2]

  def add_entity(id, components, type) do
    ConCache.put(:entity_cache, id, {components, type, :false})
    if type == :permanent do
      Repo.insert %Entity{id: id, components: components}
    end
  end

  def delete_entity(id) do
    {components, type, _dirty} = ConCache.get(:entity_cache, id)
    ConCache.delete(:entity_cache, id)
    if type == :permanent do
      Repo.delete %Entity{id: id}
    end
  end

  def update_entity(id, component, key, value) do
    {components, type, _dirty} = ConCache.get(:entity_cache, id)
    components = put_in(components, [component, key], value)
    ConCache.put(:entity_cache, id, {components, type, true})
  end

  def get_entity(id) do
    ConCache.get(:entity_cache, id)
  end

  def load_all_entities do
    query = from e in Entity,
      select: e
    query
    |> Repo.all
    |> Enum.each(fn(entity) ->
      ConCache.put(:entity_cache, entity.id, {entity.components, :permanent, :false})
    end)
  end

  def save_all_entities do
    :entity_cache
    |> ConCache.ets
    |> :ets.foldl(fn({id, {components, type, dirty}}) ->
      if type == :permanent and dirty == true do
        Repo.update %Entity{id: id, components: components}
      end
    end)
  end

  def empty_cache do
    :entity_cache
    |> ConCache.ets
    |> :ets.delete_all_objects
  end
end