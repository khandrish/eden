defmodule Exmud.Db do
  @moduledoc """
  Acts as an abstraction around whatever the data storage logic actually is.
  """
  use Execs.Utils

  @opaque id :: integer()
  @type component :: atom()
  @type component_list :: [component]
  @type component_match :: %{id: id, components: %{component => boolean()}}
  @type component_match_list :: [component_match]
  @type entity :: %{id: id, components: %{component => kv_pairs}}
  @type entity_list :: [entity]
  @type key :: any()
  @type key_match :: %{id: id, components: %{component => %{key => boolean()}}}
  @type key_match_list :: [key_match]
  @type kv_pairs :: map()
  @type id_list :: [id]
  @type id_match :: %{id: id, result: boolean()}
  @type id_match_list :: [id_match]
  @type fun_list :: [fun()]
  @type key_list :: [key]
  @type list_keys :: %{id: id, components: %{component => [key]}}
  @type list_keys_list :: [list_keys]
  @type list_components :: %{id: id, components: maybe_component_list}
  @type list_components_list :: [list_components]
  @type maybe_component_list :: component | component_list
  @type maybe_component_match_list :: component_match | component_match_list
  @type maybe_entity_list :: entity | entity_list
  @type maybe_fun_list :: fun | fun_list
  @type maybe_id_list :: id | id_list
  @type maybe_id_match_list :: id_match | id_match_list
  @type maybe_key_list :: key | key_list
  @type maybe_key_match_list :: key_match | key_match_list
  @type maybe_list_components_list :: list_components | list_components_list
  @type maybe_list_keys_list :: list_keys | list_keys_list


  #
  # API
  #


  @doc """
  All data manipulation functions expect to be performed in the context of a
  transaction. This ensures all systems can run concurrently while safely
  accessing data.
  """
  @spec transaction(fun()) :: any()
  def transaction(block), do: Execs.transaction(block)

  @doc """
  Create a single entity and return the id.
  """
  @spec create() :: id
  def create, do: hd(create(1))

  @doc """
  Create the specified number of entities and return their ids.
  """
  @spec create(integer()) :: id_list
  def create(n), do: Execs.create(n)

  @doc """
  Delete a set of entities and all their data.
  """
  @spec delete(maybe_id_list) :: maybe_entity_list
  def delete(ids), do: Execs.delete(ids)

  @doc """
  Delete a set of components and all their data from a set of entities.
  """
  @spec delete(maybe_id_list, maybe_component_list) :: maybe_entity_list
  def delete(ids, components) do
    Execs.delete(ids, components)
  end

  @doc """
  Delete a set of keys from a set of components which belong to a set of entities.
  """
  @spec delete(maybe_id_list, maybe_component_list, maybe_key_list) :: maybe_entity_list
  def delete(ids, components, keys) do
    Execs.delete(ids, components, keys)
  end

  @doc """
  Check to see if a set of entities has a set of components.
  """
  @spec has_all(maybe_id_list, maybe_component_list) :: maybe_id_match_list
  def has_all(ids, components)  do
    Execs.has_all(ids, components)
  end

  @doc """
  Check to see if a set of entities has set of keys.
  """
  @spec has_all(maybe_id_list, maybe_component_list, maybe_key_list) :: maybe_id_match_list
  def has_all(ids, components, keys) do
    Execs.has_all(ids, components, keys)
  end

  @doc """
  Check to see if a set of entities has set of keys. The value associated with the each key
  is passed to each of the comparison functions. If all functions return true then there is
  a match.
  """
  @spec has_all(maybe_id_list, maybe_component_list, maybe_key_list, maybe_fun_list) :: maybe_id_match_list
  def has_all(ids, components, keys, functions) do
    Execs.has_all(ids, components, keys, functions)
  end

  @doc """
  Check to see if a set of entities has at least one of a set of components.
  """
  @spec has_any(maybe_id_list, maybe_component_list) :: maybe_id_match_list
  def has_any(ids, components) do
    Execs.has_any(ids, components)
  end

  @doc """
  Check to see if a set of entities has at least one of a set of keys.
  """
  @spec has_any(maybe_id_list, maybe_component_list, maybe_key_list) :: maybe_id_match_list
  def has_any(ids, components, keys) do
    Execs.has_any(ids, components, keys)
  end

  @doc """
  Check to see if a set of entities has at least one of a set of keys. The value associated
  with the each key is passed to each of the comparison functions. If all functions return
  true then there is a match.
  """
  @spec has_any(maybe_id_list, maybe_component_list, maybe_key_list, maybe_fun_list) :: maybe_id_match_list
  def has_any(ids, components, keys, functions) do
    Execs.has_any(ids, components, keys, functions)
  end

  @doc """
  Check to see which of a set of components a set of entities has.
  """
  @spec has_which(maybe_id_list, maybe_component_list) :: maybe_component_match_list
  def has_which(ids, components) do
    Execs.has_which(ids, components)
  end

  @doc """
  Check to see which of a set of keys a set of entities has.
  """
  @spec has_which(maybe_id_list, maybe_component_list, maybe_key_list) ::maybe_component_match_list
  def has_which(ids, components, keys) do
    Execs.has_which(ids, components, keys)
  end

  @doc """
  Check to see which of a set of keys a set of entities has. The value associated
  with the each key is passed to each of the comparison functions. If all functions return
  true then there is a match.
  """
  @spec has_which(maybe_id_list, maybe_component_list, maybe_key_list, maybe_fun_list) :: maybe_component_match_list
  def has_which(ids, components, keys, functions) do
    Execs.has_which(ids, components, keys, functions)
  end

  @doc """
  List the components of a set of entities.
  """
  @spec list(maybe_id_list) :: maybe_list_components_list
  def list(ids), do: Execs.list(ids)

  @doc """
  List the keys belonging to a set of components of a set of entities.
  """
  @spec list(maybe_id_list, maybe_component_list) :: maybe_list_keys_list
  def list(ids, components) do
    Execs.list(ids, components)
  end

  @doc """
  List the entities which have a set of components.
  """
  @spec find_with_all(maybe_component_list) :: id_list
  def find_with_all(components) do
    Execs.find_with_all(components)
  end

  @doc """
  List the entities which have a set of keys.
  """
  @spec find_with_all(maybe_component_list, maybe_key_list) :: id_list
  def find_with_all(components, keys) do
    Execs.find_with_all(components, keys)
  end

  @doc """
  List the entities which have a set of keys. The value associated
  with the each key is passed to each of the comparison functions. If all functions return
  true then there is a match.
  """
  @spec find_with_all(maybe_component_list, maybe_key_list, maybe_fun_list) :: id_list
  def find_with_all(components, keys, functions) do
    Execs.find_with_all(components,
                     keys,
                     functions)
  end

  @doc """
  List the entities which have at least one of a set of components.
  """
  @spec find_with_any(maybe_component_list) :: id_list
  def find_with_any(components) do
    Execs.find_with_any(components)
  end

  @doc """
  List the entities which have at least one of a set of keys.
  """
  @spec find_with_any(maybe_component_list, maybe_key_list) :: id_list
  def find_with_any(components, keys) do
    Execs.find_with_any(components, keys)
  end

  @doc """
  List the entities which have at least one of a set of keys. The value associated
  with the each key is passed to each of the comparison functions. If all functions return
  true then there is a match.
  """
  @spec find_with_any(maybe_component_list, maybe_key_list, maybe_fun_list) :: id_list
  def find_with_any(components, keys, functions) do
    Execs.find_with_any(components, keys, functions)
  end

  @doc """
  Read a set of entities.
  """
  @spec read(maybe_id_list) :: maybe_entity_list
  def read(ids), do: Execs.read(ids)

  @doc """
  Read a set of components belonging to a set of entities.
  """
  @spec read(maybe_id_list, maybe_component_list) :: maybe_entity_list
  def read(ids, components) do
    Execs.read(ids, components)
  end

  @doc """
  Read a set of keys belonging to a set of entities. Providing anything other
  than a single id, component, and key will return a map otherwise a single
  value is returned.
  """
  @spec read(maybe_id_list, maybe_component_list, maybe_key_list) :: maybe_entity_list | any()
  def read(ids, components, keys) do
    Execs.read(ids, components, keys)
  end

  @doc """
  Write a value to any combination of keys, components, and entities.
  """
  @spec write(maybe_id_list, maybe_component_list, maybe_key_list, any()) :: maybe_id_list
  def write(ids, components, keys, value) do
    Execs.write(ids, components, keys, value)
  end
end
