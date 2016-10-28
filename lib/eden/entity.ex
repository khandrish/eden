defmodule Eden.Entity do
  @moduledoc """
  All manipulation of system state is handled through this module.

  The functions in this module assume that they are being called in the context
  of a transaction and will raise an exception if they aren't. See
  Eden.Db.transaction/1 for details.
  """  
  # require Logger

  # @component_flag :component
  # @db_client Application.get_env(:eden, :db_client)
  # @entity_component Application.get_env(:eden, :entity_component)

  #
  # API
  #

  # def transaction(block) do
  #   @db_client.transaction(block)
  # end

  @doc """
  Creates a new entity within the system, returning the new id
  """
  # def new do
  #   @db_client.new_entity()
  #   |> add_component(@entity_component)
  # end

  # Manipulation at the entity level

  # def delete(entities) when is_list(entities) do
  #   @db_client.delete_entities(entities)
  # end

  # def delete(entity) do
  #   delete([entity])
  # end

  # def get(entities) when is_list(entities) do
  #   @db_client.get(entities)
  # end

  # def get(entity) do
  #   case get([entity]) do
  #     [] -> nil
  #     [result] -> result
  #   end
  # end

  # Manipulation at the component level

  # def add_component(entity, component) do
  #   Logger.debug("Adding #{component} to #{entity}")
  #   @db_client.add_component(entity, component)
  #   component.init(entity)
  # end

  # def has_component?(entity, component) do
  #   @db_client.has_component?(entity, component)
  # end

  # def list_components(entity) do
  #   @db_client.list_components(entity)
  # end

  # def list_with_components(components) when is_list(components) do
  #   @db_client.list_with_components(components)
  # end

  # def list_with_components(component) do
  #   list_with_components([component])
  # end

  # def remove_component(entity, component) do
  #   component.destroy(entity)
  #   @db_client.remove_component(entity, component)
  # end

  # Manipulation at the key level

  # def add_key(entity, component, key, value \\ nil) do
  #   Logger.debug("Adding #{key} to #{component} of #{entity}")
  #   @db_client.add_key(entity, component, key, value)
  # end

  # def get_all_keys(component, key) do
  #   @db_client.get_all_keys(component, key)
  # end

  # def get_key(entity, component, key) do
  #   @db_client.get_key(entity, component, key)
  # end

  # def has_key?(entity, component, key) do
  #   @db_client.has_key?(entity, component, key)
  # end

  # def put_key(entity, component, key, value \\ nil) do
  #   @db_client.put_key(entity, component, key, value)
  # end

  # def remove_key(entity, component, key) do
  #   @db_client.remove_key(entity, component, key)
  # end

  # # Manipulation at the value level
  # def value_exists?(component, key, value) do
  #   Logger.debug("Checking #{key} of #{component}")
  #   @db_client.value_exists?(component, key, value)
  # end

  #
  # Private functions
  #
end