defmodule Eden.DbClient.Mnesia do
  @moduledoc false
  
  require Record
  require Qlc

  #@behaviour Eden.DbClient.Client

  @component_flag :component

  @entity_component Application.get_env(:eden, :entity_component)

  @entity [table: nil, autoincrement_id: nil]
  @data [id: nil, component: nil, key: nil, value: nil]

  @entity_fields Keyword.keys(@entity)
  @data_fields Keyword.keys(@data)

  Record.defrecord :entity, @entity
  Record.defrecord :data, @data


  #
  # API
  #

  def initialize do
    case :mnesia.create_table(:entity, [attributes: @entity_fields]) do
      {:atomic, :ok} -> :ok
      {:aborted, {:already_exists, :entity}} -> :ok
    end
    case :mnesia.create_table(:data, [attributes: @data_fields, type: :bag]) do
      {:atomic, :ok} ->
        {:atomic, :ok} = :mnesia.add_table_index(:data, :component)
        {:atomic, :ok} = :mnesia.add_table_index(:data, :key)
        :ok
      {:aborted, {:already_exists, :data}} ->
        :ok
    end
  end


  def transaction(block) do
    case :mnesia.transaction(block) do
      {:atomic, result} -> result
      error_result -> error_result
    end
  end

  # Creating entities

  def create(), do: hd(create(1))
  def create(total) do
    for _ <- 1..total,
      do: :mnesia.dirty_update_counter(:entity, :autoincrement_id, 1)
  end


  # Deleting entities

  def delete(ids) do
    initial_results = for id <- ids, do: {id, %{}}

    entities = read(ids)
    
    Enum.each(ids, &(:mnesia.delete({:data, &1})))
    
    Stream.concat(entities, initial_results)
    |> Enum.dedup_by(fn({id, _}) -> id end)
  end


  # Deleting components

  def delete(ids, components) do
    initial_results = for id <- ids, do: {id, %{}}

    entities = read(ids, components)
    
    ickv_from_ic_query(ids, components)
    |> Qlc.e()
    |> Enum.each(fn({id, component, key, value}) ->
      :mnesia.delete_object(data(id: id, component: component, key: key, value: value))
    end)

    Stream.concat(entities, initial_results)
    |> Enum.dedup_by(fn({id, _}) -> id end)
  end


  # Deleting keys

  def delete(ids, components, keys) do
    initial_results = for id <- ids, do: {id, %{}}

    entities = read(ids, components, keys)
    
    ickv_from_ick_query(ids, components, keys)
    |> Qlc.e()
    |> Enum.each(fn({id, component, key, value}) ->
      :mnesia.delete_object(data(id: id, component: component, key: key, value: value))
    end)

    Stream.concat(entities, initial_results)
    |> Enum.dedup_by(fn({id, _}) -> id end)
  end


  # Querying existence of components

  def has_all(ids, components) do
    initial_results = Map.new(ids, &({&1, 0}))

    ic_from_ic_query(ids, components)
    |> Qlc.e()
    |> Stream.uniq()
    |> Enum.reduce(initial_results, fn({id, _component}, results) ->
      Map.update(results, id, 0, &(&1 + 1))
    end)
    |> Enum.map(fn({id, count_passed}) ->
      {id, count_passed === length(components)}
    end)
  end

  def has_any(ids, components) do
    for id <- Qlc.e(i_from_ic_query(ids, components)),
      into: Map.new(ids, &({&1, false}))
      do
      {id, true}
    end
    |> Map.to_list()
  end

  def has_which(ids, components) do
    component_results = Map.new(components, &({&1, false}))
    initial_results = Map.new(ids, &({&1, component_results}))

    ic_from_ic_query(ids, components)
    |> Qlc.e()
    |> Enum.reduce(initial_results, fn({id, component}, results) ->
      results
      |> put_in([id, component], true)
    end)
    |> Map.to_list()
  end


  # Querying existence of keys

  def has_all(ids,
               components,
               keys) do
    initial_results = Map.new(ids, &({&1, 0}))

    i_from_ick_query(ids, components, keys)
    |> Qlc.e()
    |> Enum.reduce(initial_results, fn(id, results) ->
      Map.update(results, id, 0, &(&1 + 1))
    end)
    |> Enum.map(fn({id, count_passed}) ->
      {id, count_passed === length(components) * length(keys)}
    end)
  end

  def has_any(ids,
               components,
               keys) do
    for id <- Qlc.e(i_from_ick_query(ids, components, keys)),
      into: Map.new(ids, &({&1, false}))
      do
      {id, true}
    end
    |> Map.to_list()
  end

  def has_which(ids,
               components,
               keys) do
    key_results = Map.new(keys, &({&1, false}))
    component_results = Map.new(components, &({&1, key_results}))
    initial_results = Map.new(ids, &({&1, component_results}))

    ick_from_ick_query(ids, components, keys)
    |> Qlc.e()
    |> Enum.reduce(initial_results, fn({id, component, key}, results) ->
      put_in(results, [id, component, key], true)
    end)
    |> Map.to_list()
  end


  # Querying and comparing

  def has_all(ids,
               components,
               keys,
               comparison_funs) do
    initial_results = Map.new(ids, &({&1, 0}))

    iv_from_ick_query(ids, components, keys)
    |> Qlc.e()
    |> Enum.reduce(initial_results, fn({id, value}, results) ->
      Enum.reduce(comparison_funs, nil,
        fn(_cf, false) -> false
          (cf, _) -> cf.(value)
      end)
      |> (fn(true) -> 1; (_) -> 0 end).()
      |> (&(Map.update(results, id, 0, fn(num) -> num + &1 end))).()
    end)
    |> Enum.map(fn({id, count_passed}) ->
      {id, count_passed === length(components) * length(keys)}
    end)
  end

  def has_any(ids,
               components,
               keys,
               comparison_funs) do
    initial_results = Map.new(ids, &({&1, nil}))

    iv_from_ick_query(ids, components, keys)
    |> Qlc.e()
    |> Enum.reduce(initial_results, fn({id, value}, results) ->
      Enum.reduce(comparison_funs, nil,
        fn(_cf, true) -> true
          (cf, _) -> cf.(value)
      end)
      |> (&(Map.update(results, id, nil,
        fn(true) -> true
          (_) -> &1
      end))).()
    end)
    |> Enum.map(fn({id, nil}) -> {id, false}; (result) -> result end)
  end

  def has_which(ids,
               components,
               keys,
               comparison_funs) do
    key_results = Map.new(keys, &({&1, false}))
    component_results = Map.new(components, &({&1, key_results}))
    initial_results = Map.new(ids, &({&1, component_results}))

    ickv_from_ick_query(ids, components, keys)
    |> Qlc.e()
    |> Enum.reduce(initial_results, fn({id, component, key, value}, results) ->
      Enum.reduce(comparison_funs, nil,
        fn(_cf, false) -> false
          (cf, _) -> cf.(value)
      end)
      |> (&(put_in(results, [id, component, key], &1))).()
    end)
    |> Map.to_list()
  end

  # Listing components
  
  def list(ids) do
    ic_from_i_query(ids)
    |> Qlc.e()
    |> Enum.reduce(%{}, fn({id, component}, results) ->
      results
      |> Map.put_new(id, MapSet.new())
      |> update_in([id], &(MapSet.put(&1, component)))
    end)
    |> Enum.map(fn({id, components}) ->
      {id, MapSet.to_list(components)}
    end)
  end

  # Listing keys of components
  
  def list(ids, components) do
    ick_from_ic_query(ids, components)
    |> Qlc.e()
    |> Enum.reduce(%{}, fn({id, component, key}, results) ->
      Map.put_new(results, id, %{})
      |> update_in([id], &(Map.put_new(&1, component, MapSet.new())))
      |> update_in([id, component], &(MapSet.put(&1, key)))
    end)
    |> Enum.map(fn({id, comps}) ->
      for {component, keys} <- comps,
        into: %{}
        do
        {component, MapSet.to_list(keys)}
      end
      |> (&({id, &1})).()
    end)
  end

  # Finding entities
  
  def find_with_all(components) do
    ic_from_c_query(components)
    |> Qlc.e()
    |> Stream.uniq()
    |> Enum.reduce(%{}, fn({id, _component}, results) ->
      Map.put_new(results, id, 0)
      |> update_in([id], &(&1 + 1))
    end)
    |> Stream.map(fn({id, count}) ->
      {id, count === length(components)}
    end)
    |> Stream.filter(&(elem(&1, 1)))
    |> Enum.map(&(elem(&1, 0)))
  end

  def find_with_any(components) do
     i_from_c_query(components)
    |> Qlc.e()
    |> Enum.reduce(MapSet.new(), fn(id, results) ->
      MapSet.put(results, id)
    end)
    |> MapSet.to_list()
  end

  def find_with_all(components, keys) do
    i_from_ck_query(components, keys)
    |> Qlc.e()
    |> Enum.reduce(%{}, fn(id, results) ->
      Map.put_new(results, id, 0)
      |> update_in([id], &(&1 + 1))
    end)
    |> Stream.map(fn({id, count}) ->
      {id, count === length(components) * length(keys)}
    end)
    |> Stream.filter(&(elem(&1, 1)))
    |> Enum.map(&(elem(&1, 0)))
  end

  def find_with_any(components, keys) do
    i_from_ck_query(components, keys)
    |> Qlc.e()
    |> Enum.reduce(MapSet.new(), fn(id, results) ->
      MapSet.put(results, id)
    end)
    |> MapSet.to_list()
  end

  def find_with_all(components, keys, comparison_funs) do
    iv_from_ck_query(components, keys)
    |> Qlc.e()
    |> Enum.reduce(%{}, fn({id, value}, results) ->
      results = Map.put_new(results, id, 0)

      Enum.reduce(comparison_funs, nil,
        fn(_cf, false) -> false
          (cf, _) -> cf.(value)
      end)
      |> (fn(true) -> 1; (_) -> 0 end).()
      |> (&(Map.update(results, id, 0, fn(num) -> num + &1 end))).()
    end)
    |> Stream.map(fn({id, count_passed}) ->
      {id, count_passed === length(components) * length(keys)}
    end)
    |> Stream.filter(&(elem(&1, 1)))
    |> Enum.map(&(elem(&1, 0)))
  end

  def find_with_any(components, keys, comparison_funs) do
    iv_from_ck_query(components, keys)
    |> Qlc.e()
    |> Enum.reduce(MapSet.new(), fn({id, value}, results) ->
      Enum.reduce(comparison_funs, nil,
        fn(_cf, true) -> true
          (cf, _) -> cf.(value)
      end)
      |> (&(MapSet.put(results, {id, &1}))).()
    end)
    |> Enum.filter(&(elem(&1, 1)))
    |> Enum.uniq()
    |> Enum.map(&(elem(&1, 0)))
  end

  # Reading entire entities

  def read(ids) do
    ickv_from_i_query(ids)
    |> Qlc.e()
    |> deserialize_entities()
  end

  # Reading whole components
  
  def read(ids, components) do
    ickv_from_ic_query(ids, components)
    |> Qlc.e()
    |> deserialize_entities()
  end

  # Reading specific keys
  
  def read(ids, components, keys) do
    ickv_from_ick_query(ids, components, keys)
    |> Qlc.e()
    |> deserialize_entities()
  end

  # Writing values

  def write(ids, components, keys, value) do
    for id <- ids, component <- components, key <- keys do
      {id, component, key}
    end
    |> Enum.each(fn({id, component, key}) ->
      data(id: id, component: component, key: key, value: value)
      |> :mnesia.write()
    end)
  end


  #
  # Private functions
  #


  defp deserialize_entities(results) do
    results
    |> Enum.reduce(%{}, fn({id, component, key, value}, results) ->
      results
      |> Map.put_new(id, %{})
      |> update_in([id], &(Map.put_new(&1, component, %{})))
      |> update_in([id, component], &(Map.put(&1, key, value)))
    end)
    |> Map.to_list()
  end

  defp i_from_c_query(components) do
    """
    [Id ||
      {_, Id, Component, _, _} <- Data,
      Wanted_component <- Components,
      Wanted_component =:= Component
    ]
    """
    |> Qlc.q([Data: :mnesia.table(:data), Components: components])
  end

  defp i_from_ck_query(components, keys) do
    """
    [Id ||
      {_, Id, Component, Key, _} <- Data,
      Wanted_component <- Components,
      Wanted_key <- Keys,
      Wanted_component =:= Component,
      Key =:= Wanted_key
    ]
    """
    |> Qlc.q([Data: :mnesia.table(:data), Components: components, Keys: keys])
  end

  defp i_from_ic_query(ids, components) do
    """
    [Id ||
      {_, Id, Component, _, _} <- Data,
      Wanted_id <- Ids,
      Wanted_component <- Components,
      Id =:= Wanted_id,
      Component =:= Wanted_component
    ]
    """
    |> Qlc.q([Data: :mnesia.table(:data), Ids: ids, Components: components])
  end

  defp i_from_ick_query(ids, components, keys) do
    """
    [Id ||
      {_, Id, Component, Key, _} <- Data,
      Wanted_id <- Ids,
      Wanted_component <- Components,
      Wanted_key <- Keys,
      Id =:= Wanted_id,
      Component =:= Wanted_component,
      Key =:= Wanted_key
    ]
    """
    |> Qlc.q([Data: :mnesia.table(:data),
              Ids: ids,
              Components: components,
              Keys: keys])
  end

  defp ic_from_c_query(components) do
    """
    [{Id, Component} ||
      {_, Id, Component, _, _} <- Data,
      Wanted_component <- Components,
      Component =:= Wanted_component
    ]
    """
    |> Qlc.q([Data: :mnesia.table(:data), Components: components])
  end

  defp ic_from_i_query(ids) do
    """
    [{Id, Component} ||
      {_, Id, Component, _, _} <- Data,
      Wanted_id <- Ids,
      Wanted_id =:= Id
    ]
    """
    |> Qlc.q([Data: :mnesia.table(:data), Ids: ids])
  end

  defp ic_from_ic_query(ids, components) do
    """
    [{Id, Component} ||
      {_, Id, Component, _, _} <- Data,
      Wanted_id <- Ids,
      Wanted_component <- Components,
      Wanted_id =:= Id,
      Component =:= Wanted_component
    ]
    """
    |> Qlc.q([Data: :mnesia.table(:data), Ids: ids, Components: components])
  end

  defp iv_from_ck_query(components, keys) do
    """
    [{Id, Value} ||
      {_, Id, Component, Key, Value} <- Data,
      Wanted_component <- Components,
      Wanted_key <- Keys,
      Component =:= Wanted_component,
      Key =:= Wanted_key
    ]
    """
    |> Qlc.q([Data: :mnesia.table(:data), Components: components, Keys: keys])
  end

  defp iv_from_ick_query(ids, components, keys) do
    """
    [{Id, Value} ||
      {_, Id, Component, Key, Value} <- Data,
      Wanted_id <- Ids,
      Wanted_component <- Components,
      Id =:= Wanted_id,
      Component =:= Wanted_component
    ]
    """
    |> Qlc.q([Data: :mnesia.table(:data),
              Ids: ids,
              Components: components,
              Keys: keys])
  end

  defp ick_from_ic_query(ids, components) do
    """
    [{Id, Component, Key} ||
      {_, Id, Component, Key, _} <- Data,
      Wanted_id <- Ids,
      Wanted_component <- Components,
      Wanted_id =:= Id,
      Wanted_component =:= Component
    ]
    """
    |> Qlc.q([Data: :mnesia.table(:data), Ids: ids, Components: components])
  end

  defp ick_from_ick_query(ids, components, keys) do
    """
    [{Id, Component, Key} ||
      {_, Id, Component, Key, _} <- Data,
      Wanted_id <- Ids,
      Wanted_component <- Components,
      Wanted_key <- Keys,
      Id =:= Wanted_id,
      Component =:= Wanted_component,
      Key =:= Wanted_key
    ]
    """
    |> Qlc.q([Data: :mnesia.table(:data),
              Ids: ids,
              Components: components,
              Keys: keys])
  end

  defp ickv_from_i_query(ids) do
    """
    [{Id, Component, Key, Value} ||
      {_, Id, Component, Key, Value} <- Data,
      Wanted_id <- Ids,
      Id =:= Wanted_id
    ]
    """
    |> Qlc.q([Data: :mnesia.table(:data),
              Ids: ids])
  end

  defp ickv_from_ic_query(ids, components) do
    """
    [{Id, Component, Key, Value} ||
      {_, Id, Component, Key, Value} <- Data,
      Wanted_id <- Ids,
      Wanted_component <- Components,
      Id =:= Wanted_id,
      Component =:= Wanted_component
    ]
    """
    |> Qlc.q([Data: :mnesia.table(:data),
              Ids: ids,
              Components: components])
  end

  defp ickv_from_ick_query(ids, components, keys) do
    """
    [{Id, Component, Key, Value} ||
      {_, Id, Component, Key, Value} <- Data,
      Wanted_id <- Ids,
      Wanted_component <- Components,
      Wanted_key <- Keys,
      Id =:= Wanted_id,
      Component =:= Wanted_component,
      Key =:= Wanted_key
    ]
    """
    |> Qlc.q([Data: :mnesia.table(:data),
              Ids: ids,
              Components: components,
              Keys: keys])
  end
end