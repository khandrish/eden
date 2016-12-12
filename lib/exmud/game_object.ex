defmodule Exmud.GameObject do
  alias Exmud.Repo
  alias Exmud.Schema.Alias
  alias Exmud.Schema.Attribute
  alias Exmud.Schema.Callback
  alias Exmud.Schema.CommandSet
  alias Exmud.Schema.GameObject, as: GO
  alias Exmud.Schema.Lock
  alias Exmud.Schema.Relationship
  alias Exmud.Schema.Script
  alias Exmud.Schema.Tag
  import Ecto.Query
  use NamedArgs
  
  
  def access(_accessor, _type) do
  
  end
  
  @default_move_args %{quiet: false}
  def move(_traversing_object, _traversed_object, args \\ @default_move_args) do
    normalize_args(@default_move_args, args)
    # if Hook.call_hook(traversing_object, "before_move", [traversing_object, args]) do
    #   if Hook.call_hook(traversing_object, "before_traverse", [traversing_object, traversed_object, args]) do
    #     if args.quiet != true do
    #       message =  Hook.call_hook(traversing_object, "announce_move_from", [traversing_object, args])
    #       puppets = get all puppeted objects in the current traversing_object location
    #       send message to sessions puppeting the puppets
    #     end
    #     get destination from traversed_object
    #     update location for traversing_object to destination
    #     if args.quiet != true do
    #       message =  Hook.call_hook(traversing_object, "announce_move_to", [traversing_object, args])
    #       puppets = get all puppeted objects in the current traversing_object location
    #       send message to sessions puppeting the puppets
    #     end
    #   Hook.call_hook(traversed_object, "after_traverse", [traversed_object, args])
    #   Hook.call_hook(traversing_object, "after_traverse", [traversing_object, args])
  
  end
  
  # Game Object management
  
  def new(key) do
    case Repo.insert(GO.changeset(%GO{}, %{key: key, date_created: Ecto.DateTime.utc()})) do
      {:ok, object} -> {:ok, object.id}
      {:error, changeset} ->
        {:error, changeset.errors}
    end
  end
  
  def delete(oid) do
    case Repo.get(GO, oid) do
      nil -> :ok
      object ->
        case Repo.delete(object) do
          {:ok, _} -> :ok
          result -> result
        end
    end
  end
  
  # TODO: Revisit the whole list concept before finishing work on it
  def list(options) when is_list(options) do
    list(:and, options)
  end
  
  def list(type, options \\ [attributes: [], callbacks: [], command_sets: [], keys: [], locks: [], relationships: [], scripts: [], tags: []])
  
  def list(_type, keys: keys) do
    keys = List.wrap(keys)
    
    Repo.all(
      from object in GO,
        where: object.key in ^keys,
        select: object.id
    )
  end
  
  def list(:and, tags: tags) do
    tags = List.wrap(tags)
    required_count = length(tags)
    
    Repo.all(
      from tag in Tag,
        where: tag.tag in ^tags,
        group_by: tag.oid,
        having: count(tag.oid) == ^required_count,
        select: tag.oid
    )
  end
  
  def list(:or, tags: tags) do
    tags = List.wrap(tags)
    
    Repo.all(
      from tag in Tag,
        where: tag.tag in ^tags,
        select: tag.oid
    )
  end
  

  # TODO: Find a hell of a lot better way to do this
  def list(type, options) do
    aliases = List.wrap(options[:aliases])
    aliases_required_count = length(aliases)
    attributes = List.wrap(options[:attributes])
    attributes_required_count = length(attributes)
    homes = List.wrap(options[:homes])
    homes_required_count = length(homes)
    keys = List.wrap(options[:keys])
    locations = List.wrap(options[:locations])
    locations_required_count = length(locations)
    tags = List.wrap(options[:tags])
    tags_required_count = length(tags)
    
    query =
      from object in GO,
        group_by: object.id,
        select: object
        
    query =
      case {query, type, length(aliases) > 0} do
        {query, :and, true} ->
          from object in query,
            inner_join: alias in assoc(object, :aliases), on: object.id == alias.oid,
            where: alias.alias in ^aliases,
            group_by: alias.oid,
            having: count(alias.oid) == ^aliases_required_count
        {query, :or, true} ->
          from object in query,
            inner_join: alias in assoc(object, :aliases), on: object.id == alias.oid,
            where: alias.alias in ^aliases
        {query, _, _} -> query
      end
      
    query =
      case {query, type, length(attributes) > 0} do
        {query, :and, true} ->
          from object in query,
            inner_join: attribute in assoc(object, :attributes), on: object.id == attribute.oid,
            where: attribute.name in ^attributes,
            group_by: attribute.oid,
            having: count(attribute.oid) == ^attributes_required_count
        {query, :or, true} ->
          from object in query,
            inner_join: attribute in assoc(object, :attributes), on: object.id == attribute.oid,
            where: attribute.name in ^attributes
        {query, _, _} -> query
      end
      
    query =
      case {query, type, length(homes) > 0} do
        {query, :and, true} ->
          from object in query,
            inner_join: home in assoc(object, :homes), on: object.id == home.oid,
            where: home.homes in ^homes,
            group_by: home.oid,
            having: count(home.oid) == ^homes_required_count
        {query, :or, true} ->
          from object in query,
            inner_join: home in assoc(object, :homes), on: object.id == home.oid,
            where: home.homes in ^homes
        {query, _, _} -> query
      end
      
    query =
      case {query, type, length(keys) > 0} do
        {query, _, true} ->
          from object in query,
            where: object.key in ^keys
        {query, _, _} -> query
      end
      
    query =
      case {query, type, length(locations) > 0} do
        {query, :and, true} ->
          from object in query,
            inner_join: location in assoc(object, :locations), on: object.id == location.oid,
            where: location.location in ^locations,
            group_by: location.oid,
            having: count(location.oid) == ^locations_required_count
        {query, :or, true} ->
          from object in query,
            inner_join: location in assoc(object, :locations), on: object.id == location.oid,
            where: location.location in ^locations
        {query, _, _} -> query
      end
      
    query =
      case {query, type, length(tags) > 0} do
        {query, :and, true} ->
          from object in query,
            inner_join: tag in assoc(object, :tags), on: object.id == tag.oid,
            where: tag.tag in ^tags,
            group_by: tag.oid,
            having: count(tag.oid) == ^tags_required_count
        {query, :or, true} ->
          from object in query,
            inner_join: tag in assoc(object, :tags), on: object.id == tag.oid,
            where: tag.tag in ^tags
        {query, _, _} -> query
      end
      
    Repo.all(query)
  end
  
  
  #
  # Private functions
  #
  
  defp normalize_args(default, args) do
    Map.merge(default, args)
  end
end