defmodule Eden.DbClient.Client do
  @moduledoc """
  Data manipulation is handled through clients which implement this interface.
  """  

  # @opaque id :: integer()
  # @type boolean_search_type :: :and | :or
  # @type component :: atom()
  # @type component_match :: %{id => %{component => boolean()}}
  # @type components :: %{component => kv_pairs}
  # @type entities :: [entity]
  # @type entity :: %{id: id, components: components}
  # @type key :: any()
  # @type key_match :: %{id => %{component => %{key => boolean()}}}
  # @type kv_pairs :: %{...}
  # @type component_list :: [component]
  # @type id_list :: [ids]
  # @type fun_list :: [fun()]
  # @type key_list :: [key]
  # @type list_keys :: %{id => %{component => [key]}}
  # @type list_components :: %{id => [component]}

  # @callback transaction(fun()) :: any()

  # @doc """
  # Create a new entity and return the id.
  # """
  # @callback create() :: id

  # @doc """
  # Create the specified number of entities and returns the ids.
  # """
  # @callback create(total :: integer()) :: [id]

  # @doc """
  # Delete an entity and all its data.
  # """  
  # @callback delete(id_list) :: entities

  # @doc """
  # Delete a component and all its data from an entity.
  # """ 
  # @callback delete(id_list, component_list) :: entities

  # @doc """
  # Delete a key from a component of an entity.
  # """ 
  # @callback delete(id_list,
  #                  component_list,
  #                  key_list) :: entities

  # @doc """
  # Check to see if one or more entities have a component or set of components.
  # """ 
  # @callback has_all?(id_list, component_list) :: boolean()
  
  # @doc """
  # Check to see if one or more entities have a key or set of keys..
  # """ 
  # @callback has_all?(id_list,
  #                component_list,
  #                key_list) :: boolean()
  
  # @doc """
  # Check to see if one or more entities have a value. This is determined by
  # passing the value associated with the provided id to the passed in filter
  # function and evaluating the boolean result.
  # """ 
  # @callback has_all?(id_list,
  #               component_list,
  #               key_list,
  #               fun_list) :: boolean()

  # @doc """
  # Check to see if one or more entities have a component or set of components.
  # """ 
  # @callback has_any?(id_list, component_list) :: boolean()
  
  # @doc """
  # Check to see if one or more entities have a key or set of keys.
  # """ 
  # @callback has_any?(id_list,
  #                component_list,
  #                key_list) :: boolean()
  
  # @doc """
  # Check to see if one or more entities have a value. This is determined by
  # passing the value associated with the provided id to the passed in filter
  # function and evaluating the boolean result.
  # """ 
  # @callback has_any?(id_list,
  #               component_list,
  #               key_list,
  #               fun_list) :: boolean()

  # @doc """
  # Check to see if one or more entities have a component or set of components.

  # Returns a map of the results.
  # """ 
  # @callback has_which?(id_list, component_list) :: component_match

  # @doc """
  # Check to see if one or more entities have a key or set of keys.

  # Returns a map of the results.
  # """ 
  # @callback has_which?(id_list,
  #                    component_list,
  #                    key_list) :: key_match

  # @doc """
  # Check to see if one or more entities have a value. This is determined by
  # passing the value associated with the provided id to the passed in filter
  # function and evaluating the boolean result.
  # """ 
  # @callback has_which?(id_list,
  #                    component_list,
  #                    key_list,
  #                    fun_list) :: key_match

  # @doc """
  # List the components of an entity.
  # """ 
  # @callback list(id_list) :: list_components
  
  # @doc """
  # List the keys belonging to a component of an entity.
  # """ 
  # @callback list(id_list, component_list) :: list_keys

  # @doc """
  # List the entities which have a component or a set of components.
  # """ 
  # @callback find_with_all(component_list) :: [id]
  
  # @doc """
  # List the entities which have a key or set of keys.
  # """
  # @callback find_with_all(component_list, key_list) :: [id]
  
  # @doc """
  # List the entities which have certain values. This is determined by passing
  # the value to the passed in filter function and evaluating the boolean result.

  # A `true` result means that the entity which has that particular value will be
  # included in the results.
  # """
  # @callback find_with_all(component_list,
  #                 key_list,
  #                 fun_list) :: [id]

  # @doc """
  # List the entities which have at least one of a set of components.

  # Default search type should be `:and`
  # """ 
  # @callback find_with_any(component_list) :: [id]
  
  # @doc """
  # List the entities which have at least one of set of keys.
  # """
  # @callback find_with_any(component_list, key_list) :: [id]
  
  # @doc """
  # List the entities which have at least one of a set of certain values. This
  # is determined by passing the value to the passed in filter function and
  # evaluating the boolean result.

  # A `true` result means that the entity which has that particular value will be
  # included in the results.
  # """
  # @callback find_with_any(component_list,
  #                 key_list,
  #                 fun_list) :: [id]

  # @doc """
  # Read an entity or set of entities.
  # """
  # @callback read(id_list) :: entities
  
  # @doc """
  # Read a component or set of component from an entity or set of entities.
  # """
  # @callback read(id_list, component_list) :: entities
  
  # @doc """
  # Read a key or set of keys from an entity or set of entities.
  # """
  # @callback read(id_list,
  #                component_list,
  #                key_list) :: entities

  # @doc """
  # Write a value to any combination of ids, components, and entities.
  # """
  # @callback write(id_list | nil,
  #                 component_list,
  #                 key_list,
  #                 any()) :: id
end