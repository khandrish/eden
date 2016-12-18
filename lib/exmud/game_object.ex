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
   # normalize_args(@default_move_args, args)
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
  
  def list(options \\ [attributes: [], callbacks: [], command_sets: [], keys: [], locks: [], relationships: [], scripts: [], tags: []]) do
    query =
      from object in GO,
        #group_by: object.id,
        select: object.id
    
    build_query(query, options)
    |> Repo.all()
  end
  
  
  #
  # Private functions
  #
  
  
  defp build_query(query, []), do: query
  
  defp build_query(query, [{:or_attributes, [{:or, attribute} | _] = attributes} | options]) do
    build_attribute_query(query, {{:attributes, attributes}, options})
  end
  
  defp build_query(query, [{:or_attributes, [attribute | attributes]} | options]) do
    build_attribute_query(query, {{:attributes, [{:or, attribute} | attributes]}, options})
  end
  
  # Attributes query builder
  
  defp build_attribute_query(query, {[], options}) do
    build_query(query, options)
  end
  
  defp build_attribute_query(query, {{:attributes, attributes}, options}) do
    query = 
      from object in query,
        inner_join: attribute in assoc(object, :attributes), on: object.id == attribute.oid
    
    build_attribute_query(query, {attributes, options})
  end
  
  defp build_attribute_query(query, {[{:or, attribute} | attributes], options}) do
    query = 
      from object in query,
        or_where: attribute.key == ^attribute
    
    build_attribute_query(query, {attributes, options})
  end
  
  defp build_attribute_query(query, {[attribute | attributes], options}) do
    query = 
      from object in query,
        where: attribute.key == ^attribute
    
    build_attribute_query(query, {attributes, options})
  end
  
  # Callbacks query builder
  
  defp build_callback_query(query, {[], options}) do
    build_query(query, options)
  end
  
  defp build_callback_query(query, {{:callbacks, callbacks}, options}) do
    query = 
      from object in query,
        inner_join: callback in assoc(object, :callbacks), on: object.id == callback.oid
    
    build_callback_query(query, {callbacks, options})
  end
  
  defp build_callback_query(query, {[{:or, callback} | callbacks], options}) do
    query = 
      from object in query,
        or_where: callback.key == ^callback
    
    build_callback_query(query, {callbacks, options})
  end
  
  defp build_callback_query(query, {[callback | callbacks], options}) do
    query = 
      from object in query,
        where: callback.key == ^callback
    
    build_callback_query(query, {callbacks, options})
  end
  
  # Tags query builder
  
  defp build_tag_query(query, {[], options}) do
    build_query(query, options)
  end
  
  defp build_tag_query(query, {{:tags, tags}, options}) do
    query = 
      from object in query,
        inner_join: tag in assoc(object, :tags), on: object.id == tag.oid
    
    build_tag_query(query, {tags, options})
  end
  
  defp build_tag_query(query, {[{:or, {key, category}} | tags], options}) do
    query = 
      from object in query,
        or_where: [key: ^key, category: ^category]
    
    build_tag_query(query, {tags, options})
  end
  
  defp build_tag_query(query, {[{key, category} | tags], options}) do
    query = 
      from object in query,
        where: [key: ^key, category: ^category]
    
    build_tag_query(query, {tags, options})
  end
end