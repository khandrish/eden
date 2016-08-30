defmodule Eden.Entity do
  @moduledoc """
  All manipulation of system state is handled through this module.

  The functions in this module assume that they are being called in the context
  of a transaction and will raise an exception if they aren't. See
  Eden.Db.transaction/1 for details.
  """  
  alias Amnesia.Selection
  alias Eden.Database.EntityData, as: ED
  require Logger
  use Amnesia

  @component_flag :component

  #
  # API
  #

  @doc """
  Creates a new entity within the system, returning the new id
  """
  def new do
    id = ED.write(%ED{component: "entity", key: :component, value: true}).id
    add_key(id, "entity", "created", Timex.now)
    id
  end

  # Manipulation at the entity level

  def delete(entities) when is_list(entities) do
    entities
    |> Enum.each(&(delete(ED.match(id: &1))))
    true
  end

  def delete(entity) do
    ED.match(id: entity)
    |> delete()
    true
  end

  def get(entities) when is_list(entities) do
    entities
    |> Enum.map(fn(entity) -> entity |> ED.read() end)
    |> Enum.filter(&(&1))
    |> Enum.reduce(%{}, fn(data, entity_map) ->
      entity_map = Map.put_new(entity_map, List.first(data).id, %{})
      
      Enum.reduce(data, entity_map, fn(entry, map) ->
        entity = entry.id
        component = entry.component
        key = entry.key

        map = case Map.has_key?(map[entity], component) do
          false -> put_in(map, [entity, component], %{})
          _ -> map
        end
            
        put_in(map, [entity, component, key], entry.value)
      end)
    end)
    |> Enum.map(&(%{id: elem(&1, 0), components: elem(&1, 1)}))
end

  def get(entity) do
    case get([entity]) do
      [] -> nil
      [result] -> result
    end
  end

  # Manipulation at the component level

  def add_component(entity, component) do
    if has_component?(entity, component) do
      false
    else
      put_component(entity, component)
    end
  end

  def has_component?(entity, component) do
    [{{ED, :'$1', :'$2', :_ , :_},
      [{:'and', {:'==', component, :'$2'},
      {:'==', entity, :'$1'}}],
      [:'$1']}]
    |> has?()
  end

  def list_components(entity) do
    [{{ED, :'$1', :'$2', :_ , :_},
      [{:'==', entity, :'$1'}],
      [:'$2']}]
    |> select()
    |> MapSet.new()
    |> MapSet.to_list()
  end

  def list_with_components(components) when is_list(components) do
    components
    |> Enum.map(fn(component) ->
      [{{ED, :'$1', :'$2', :_ , :_},
        [{:'==', component, :'$2'}],
        [:'$1']}]
      |> select()
      |> MapSet.new()
    end)
    |> Enum.reduce(nil,
      fn(entity_set, nil) ->
        entity_set
      (entity_set, acc) ->
        MapSet.intersection(entity_set, acc)
      end)
    |> MapSet.to_list()
  end

  def list_with_components(component) do
    list_with_components([component])
  end

  def put_component(entity, component) do
    remove_component(entity, component)

    %ED{id: entity, component: component, key: @component_flag, value: true}
    |> ED.write
    :ok
  end

  def remove_component(entity, component) do
    ED.match(id: entity, component: component)
    |> do_delete()
  end

  # Manipulation at the key level

  def add_key(entity, component, key, value \\ nil) do
    if has_key?(entity, component, key) do
      false
    else
      put_key(entity, component, key, value)
    end
  end

  def get_all_keys(component, key) do
    [{{ED, :_, :'$2', :'$3' , :'$4'},
      [{:'and', {:'==', component, :'$2'},
      {:'==', key, :'$3'}}],
      [:'$4']}]
    |> select()
  end

  def get_key(entity, component, key) do
    [{{ED, :'$1', :'$2', :'$3' , :'$4'},
      [{:'and', {:'==', component, :'$2'},
      {:'==', entity, :'$1'},
      {:'==', key, :'$3'}}],
      [:'$4']}]
    |> select()
    |> List.first()
  end

  def has_key?(entity, component, key) do
    [{{ED, :'$1', :'$2', :'$3' , :_},
      [{:'and', {:'==', component, :'$2'},
      {:'==', entity, :'$1'},
      {:'==', key, :'$3'}}],
      [:'$1']}]
    |> has?()
  end

  def put_key(entity, component, key, value \\ nil) do
    if has_component?(entity, component) == false do
      add_component(entity, component)
    end

    remove_key(entity, component, key)
      
    %ED{id: entity, component: component, key: key, value: value}
    |> ED.write()
    true
  end

  def remove_key(entity, component, key) do
    ED.match(id: entity, component: component, key: key)
    |> do_delete()
  end

  #
  # Private functions
  #

  defp do_delete(object) do
    object
    |> Selection.values()
    |> Stream.each(&(ED.delete(&1)))
    |> Stream.run()
  end

  defp has?(match_spec) do
    match_spec
    |> ED.select()
    |> Selection.values()
    |> length() > 0
  end

  defp select(match_spec) do
    match_spec
    |> ED.select()
    |> Selection.values()
  end
end