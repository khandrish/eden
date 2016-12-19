defmodule Exmud.GameObject do
  alias Exmud.Repo
  alias Exmud.Schema.GameObject, as: GO
  import Ecto.Query
  use NamedArgs
  
  
  def access(_accessor, _type) do
  
  end
  
  @default_move_args %{quiet: false}
  def move(_traversing_object, _traversed_object, _args \\ @default_move_args) do
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
    case Repo.insert(GO.changeset(%GO{}, %{key: key, date_created: DateTime.utc_now()})) do
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
  
  def list(options \\ [attributes: [], callbacks: [], command_sets: [], objects: [], locks: [], relationships: [], scripts: [], tags: []])
  
  def list(options) do
    query =
      from object in GO,
        group_by: object.id,
        select: object.id
    
    list(query, options)
    |> Repo.all()
  end
  
  
  #
  # Private functions
  #
  
  
  # Attributes
  
  defp list(query, []), do: query
  defp list(query, [{_, []} | options]), do: list(query, options)
  
  defp list(query, [{:or_attributes, [{:or, _} | _] = attributes} | options]) do
    list(query, [{:attributes, attributes} | options])
  end
  
  defp list(query, [{:or_attributes, [attribute | attributes]} | options]) do
    list(query, [{:attributes, [{:or, attribute} | attributes]} | options])
  end
  
  defp list(query, [{:attributes, [{:or, attribute} | attributes]} | options]) do
    query = 
      from object in query,
        inner_join: attribute in assoc(object, :attributes), on: object.id == attribute.oid,
        or_where: attribute.key == ^attribute
    
    list(query, [{:attributes, attributes} | options])
  end
  
  defp list(query, [{:attributes, [attribute | attributes]} | options]) do
    query = 
      from object in query,
        inner_join: attribute in assoc(object, :attributes), on: object.id == attribute.oid,
        where: attribute.key == ^attribute
    
    list(query, [{:attributes, attributes} | options])
  end
  
  # Callbacks
  
  defp list(query, [{:or_callbacks, [{:or, _} | _] = callbacks} | options]) do
    list(query, [{:callbacks, callbacks} | options])
  end
  
  defp list(query, [{:or_callbacks, [callback | callbacks]} | options]) do
    list(query, [{:callbacks, [{:or, callback} | callbacks]} | options])
  end
  
  defp list(query, [{:callbacks, [{:or, callback} | callbacks]} | options]) do
    query = 
      from object in query,
        inner_join: callback in assoc(object, :callbacks), on: object.id == callback.oid,
        or_where: callback.callback == ^callback
    
    list(query, [{:callbacks, callbacks} | options])
  end
  
  defp list(query, [{:callbacks, [callback | callbacks]} | options]) do
    query = 
      from object in query,
        inner_join: callback in assoc(object, :callbacks), on: object.id == callback.oid,
        where: callback.callback == ^callback
    
    list(query, [{:callbacks, callbacks} | options])
  end
  
  
  # Command Set
  
  defp list(query, []), do: query
  defp list(query, [{_, []} | options]), do: list(query, options)
  
  defp list(query, [{:or_command_sets, [{:or, _} | _] = command_sets} | options]) do
    list(query, [{:command_sets, command_sets} | options])
  end
  
  defp list(query, [{:or_command_sets, [command_set | command_sets]} | options]) do
    list(query, [{:command_sets, [{:or, command_set} | command_sets]} | options])
  end
  
  defp list(query, [{:command_sets, [{:or, command_set} | command_sets]} | options]) do
    query = 
      from object in query,
        inner_join: command_set in assoc(object, :command_sets), on: object.id == command_set.oid,
        or_where: command_set.key == ^command_set
    
    list(query, [{:command_sets, command_sets} | options])
  end
  
  defp list(query, [{:command_sets, [command_set | command_sets]} | options]) do
    query = 
      from object in query,
        inner_join: command_set in assoc(object, :command_sets), on: object.id == command_set.oid,
        where: command_set.key == ^command_set
    
    list(query, [{:command_sets, command_sets} | options])
  end
  
  # Keys
  
  defp list(query, [{:or_objects, [{:or, _} | _] = keys} | options]) do
    list(query, [{:objects, keys} | options])
  end
  
  defp list(query, [{:or_objects, [key | keys]} | options]) do
    list(query, [{:objects, [{:or, key} | keys]} | options])
  end
  
  defp list(query, [{:objects, [{:or, key} | keys]} | options]) do
    query = 
      from object in query,
        or_where: object.key == ^key
    
    list(query, [{:objects, keys} | options])
  end
  
  defp list(query, [{:objects, [key | keys]} | options]) do
    query = 
      from object in query,
        where: object.key == ^key
    
    list(query, [{:objects, keys} | options])
  end
  
  # Tags
  
  defp list(query, [{:or_tags, [{:or, _} | _] = tags} | options]) do
    list(query, [{:tags, tags} | options])
  end
  
  defp list(query, [{:or_tags, [tag | tags]} | options]) do
    list(query, [{:tags, [{:or, tag} | tags]} | options])
  end
  
  defp list(query, [{:tags, [{:or, {key, category}} | tags]} | options]) do
    query = 
      from object in query,
        inner_join: tag in assoc(object, :tags), on: object.id == tag.oid,
        or_where: tag.key == ^key,
        where: tag.category == ^category
    
    list(query, [{:tags, tags} | options])
  end
  
  defp list(query, [{:tags, [{key, category} | tags]} | options]) do
    query = 
      from object in query,
        inner_join: tag in assoc(object, :tags), on: object.id == tag.oid,
        where: tag.key == ^key,
        where: tag.category == ^category
    
    list(query, [{:tags, tags} | options])
  end
end