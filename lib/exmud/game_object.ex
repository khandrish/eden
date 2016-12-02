defmodule Exmud.GameObject do
  alias Exmud.Repo
  alias Exmud.Schema.Alias
  alias Exmud.Schema.GameObject, as: GO
  alias Exmud.Schema.GameObjectAttribute, as: Attr
  alias Exmud.Schema.Tag
  import Ecto.Query
  import Exmud.Utils
  
  
  def access(accessor, type) do
  
  end
  
  @default_move_args %{quiet: false}
  def move(traversing_object, traversed_object, args \\ @default_move_args) do
    args = normalize_args(@default_move_args, args)
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
  
  # Attribute management
  
  def get_attribute(oid, name) do
    Repo.one(
      from attribute in Attr,
      where: attribute.name == ^name,
      where: attribute.game_object_id == ^oid,
      select: attribute.value
    )
    |> case do
      nil -> nil
      result -> :erlang.binary_to_term(result)
    end
  end
  
  def has_attribute?(oid, name) do
    find_attribute(oid, name) != nil
  end
  
  def add_attribute(oid, name, data) do
    case Repo.insert(Attr.changeset(%Attr{}, %{name: name, data: :erlang.term_to_binary(data), game_object_id: oid})) do
      {:ok, object} -> :ok
      {:error, changeset} ->
        {:error, changeset.errors}
    end
  end
  
  def remove_attribute(oid, name) do
    case find_attribute(oid, name) do
      nil -> :ok
      attribute ->
        case Repo.delete(attribute) do
          {:ok, _} -> :ok
          result -> result
        end
    end
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
  
  def list(aliases: aliases) do
    aliases = List.wrap(aliases)
    required_count = length(aliases)
    
    Repo.all(
      from alias in Alias,
        where: alias.alias in ^aliases,
        group_by: alias.id,
        having: count(alias.id) == ^required_count,
        select: alias.game_object_id
    )
  end
  
  def list(tags: tags) do
    tags = List.wrap(tags)
    required_count = length(tags)
    
    Repo.all(
      from tag in Tag,
        where: tag.tag in ^tags,
        group_by: tag.id,
        having: count(tag.id) == ^required_count,
        select: tag.game_object_id
    )
  end
  
  # Alias management
  
  def add_alias(oid, alias) do
    case Repo.insert(Alias.changeset(%Alias{}, %{date_created: Ecto.DateTime.utc(), game_object_id: oid, alias: alias})) do
      {:ok, object} -> :ok
      {:error, changeset} ->
        {:error, changeset.errors}
    end
  end
  
  def has_alias?(oid, alias) do
    find_alias(oid, alias) != nil
  end
  
  def remove_alias(oid, alias) do
    find_alias(oid, alias)
    |> case do
      nil -> :ok
      object ->
        case Repo.delete(object) do
          {:ok, _} -> :ok
          result -> result
        end
    end
  end
  
  # Tag management
  
  def add_tag(oid, tag) do
    case Repo.insert(Tag.changeset(%Tag{}, %{date_created: Ecto.DateTime.utc(), game_object_id: oid, tag: tag})) do
      {:ok, object} -> :ok
      {:error, changeset} ->
        {:error, changeset.errors}
    end
  end
  
  def has_tag?(oid, tag) do
    find_tag(oid, tag) != nil
  end
  
  def remove_tag(oid, tag) do
    find_tag(oid, tag)
    |> case do
      nil -> :ok
      object ->
        case Repo.delete(object) do
          {:ok, _} -> :ok
          result -> result
        end
    end
  end
  
  
  #
  # Private functions
  #
  
  
  defp find_alias(oid, alias) do
    Repo.one(
      from alias in Alias,
      where: alias.alias == ^alias,
      where: alias.game_object_id == ^oid
    )
  end
  
  defp find_attribute(oid, name) do
    Repo.one(
      from attribute in Attr,
      where: attribute.name == ^name,
      where: attribute.game_object_id == ^oid
    )
  end
  
  defp find_tag(oid, tag) do
    Repo.one(
      from tag in Tag,
      where: tag.tag == ^tag,
      where: tag.game_object_id == ^oid
    )
  end
  
  
  defp normalize_args(default, args) do
    Map.merge(default, args)
  end
end