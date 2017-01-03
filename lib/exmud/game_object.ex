defmodule Exmud.GameObject do
  alias Ecto.Multi
  alias Exmud.Repo
  alias Exmud.Schema.Attribute
  alias Exmud.Schema.Callback
  alias Exmud.Schema.CommandSet
  alias Exmud.Schema.Object, as: Object
  alias Exmud.Schema.Tag
  import Ecto.Query
  import Exmud.Utils
  require Logger
  use NamedArgs
  
  
  #
  # General game object functions
  #
  
  
  def new(key) do
    case Repo.insert(new_changeset(key)) do
      {:ok, object} -> {:ok, object.id}
      {:error, changeset} ->
        {:error, changeset.errors}
    end
  end
  
  def new(%Ecto.Multi{} = multi, multi_key \\ :new_game_object, key) do
    Multi.insert(multi, multi_key, new_changeset(key))
  end
  
  def delete(oid) do
    case Repo.delete(%Object{id: oid}) do
      {:ok, _} -> :ok
      result -> result
    end
  end
  
  def delete(%Ecto.Multi{} = multi, multi_key \\ :delete_game_object, oid) do
    Multi.delete(multi, multi_key, %Object{id: oid})
  end
  
  def list(options) do
    query =
      from object in Object,
        group_by: object.id,
        select: object.id
    
    list(query, options)
    |> Repo.all()
  end
  
  
  #
  # Attribute related functions
  #
  
  
  def add_attribute(oid, key, data) do
    args = %{data: :erlang.term_to_binary(data),
             key: key,
             oid: oid}
    Repo.insert(Attribute.changeset(%Attribute{}, args))
    |> normalize_noreturn_result()
  end
  
  def get_attribute(oid, key) do
    case Repo.one(attribute_query(oid, key)) do
      nil -> {:error, :no_such_attribute}
      object ->
        {:ok, :erlang.binary_to_term(object.data)}
    end
  end
  
  def has_attribute?(oid, key) do
    case Repo.one(attribute_query(oid, key)) do
      nil -> {:ok, false}
      _object -> {:ok, true}
    end
  end
  
  def remove_attribute(oid, key) do
    Repo.delete_all(attribute_query(oid, key))
    |> case do
      {1, _} -> :ok
      {0, _} -> {:error, :no_such_attribute}
      _ -> {:error, :unknown}
    end
  end
  
  def update_attribute(oid, key, data) do
    args = %{data: data,
             key: key,
             oid: oid}
    Repo.update(Attribute.changeset(%Attribute{}, args))
    |> normalize_noreturn_result()
  end
  
  
  #
  # Callback related functions
  #
  
  
  def add_callback(oid, callback, key) do
    args = %{callback: callback, key: key, oid: oid}
    Repo.insert(Callback.changeset(%Callback{}, args))
    |> normalize_noreturn_result()
    |> case do
      {:error, errors} ->
        if Keyword.has_key?(errors, :oid) do
          Logger.warn("Attempt to add callback onto non existing object `#{oid}` failed")
          {:error, :no_such_game_object}
        else
          {:error, errors}
        end
      result ->
        result
    end
  end
  
  def get_callback(oid, callback, default) do
    case Repo.one(callback_query(oid, callback)) do
      nil -> Exmud.Callback.which_module(default)
      callback -> Exmud.Callback.which_module(callback.key)
    end
  end
  
  def has_callback?(oid, callback) do
    case Repo.one(callback_query(oid, callback)) do
      nil -> {:ok, false}
      _object -> {:ok, true}
    end
  end
  
  def delete_callback(oid, callback) do
    Repo.delete_all(callback_query(oid, callback))
    |> case do
      {1, _} -> :ok
      {0, _} -> {:error, :no_such_callback}
      _ -> {:error, :unknown}
    end
  end
  
  
  #
  # Command set related functions
  #
  
  
  def add_command_set(oid, key) do
    args = %{key: key, oid: oid}
    Repo.insert(CommandSet.changeset(%CommandSet{}, args))
    |> normalize_noreturn_result()
    |> case do
      {:error, errors} ->
        if Keyword.has_key?(errors, :oid) do
          Logger.warn("Attempt to add command set onto non existing object `#{oid}` failed")
          {:error, :no_such_game_object}
        else
          {:error, errors}
        end
      result ->
        result
    end
  end
  
  def has_command_set?(oid, key) do
    case Repo.one(command_set_query(oid, key)) do
      nil -> {:ok, false}
      _object -> {:ok, true}
    end
  end
  
  def delete_command_set(oid, key) do
    Repo.delete_all(command_set_query(oid, key))
    |> case do
      {1, _} -> :ok
      {0, _} -> {:error, :no_such_command_set}
      _ -> {:error, :unknown}
    end
  end
  
  
  #
  # Tag related functions
  #
  
  def add_tag(oid, key, category \\ "__DEFAULT__") do
    args = %{category: category,
             oid: oid,
             key: key}
    Repo.insert(Tag.changeset(%Tag{}, args))
    |> normalize_noreturn_result()
  end
  
  def has_tag?(oid, key, category \\ "__DEFAULT__") do
    case Repo.one(find_tag_query(oid, key, category)) do
      nil -> {:ok, false}
      _object -> {:ok, true}
    end
  end
  
  def remove_tag(oid, key, category \\ "__DEFAULT__") do
    Repo.delete_all(
      from tag in Tag,
        where: tag.oid == ^oid,
        where: tag.key == ^key,
        where: tag.category == ^category
    )
    |> case do
      {num, _} when num > 0 -> :ok
      {0, _} -> {:error, :no_such_tag}
      _ -> {:error, :unknown}
    end
  end
  
  
  #
  # Private functions
  #
  
  
  # List Attributes
  
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
  
  # List Callbacks
  
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
  
  
  # List Command Set
  
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
  
  
  # List Keys
  
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
  
  
  # List Tags
  
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
  
  defp new_changeset(key) do
    Object.changeset(%Object{}, %{key: key, date_created: DateTime.utc_now()})
  end
  
  # Queries
  
  # Return the query used to find a specific attribute mapped to a specific object.
  defp attribute_query(oid, key) do
    from attribute in Attribute,
      where: attribute.key == ^key,
      where: attribute.oid == ^oid
  end
  
  # Return the query used to find a specific callback mapped to a specific object.
  defp callback_query(oid, callback) do
    from callback in Callback,
      where: callback.callback == ^callback,
      where: callback.oid == ^oid
  end
  
  # Return the query used to find a specific command set mapped to a specific object.
  defp command_set_query(oid, key) do
    from command_set in CommandSet,
      where: command_set.key == ^key,
      where: command_set.oid == ^oid
  end
  
  defp find_tag_query(oid, key, category) do
    from tag in Tag,
      where: tag.category == ^category,
      where: tag.key == ^key,
      where: tag.oid == ^oid
  end
end