defmodule Exmud.Tag do
  @moduledoc """
  An `Exmud.GameObject` can be tagged with arbitrary strings. In addition to
  simple tags, each tag may also be assigned to a category for additional
  flexibility.
  
  Manipulation of tags on objects is performed via this module, while
  listing of `Exmud.GameObject`'s should be performed via that module.
  """
  
  alias Exmud.Schema.GameObject
  alias Exmud.Repo
  alias Exmud.Schema.Tag
  import Ecto.Query
  import Exmud.Utils
  
  #
  # API
  #
  
  def add(oid, key, category \\ "__DEFAULT__") do
    args = %{category: category,
             oid: oid,
             key: key}
    Repo.insert(Tag.changeset(%Tag{}, args))
    |> normalize_noreturn_result()
  end
  
  def has?(oid, key, category \\ "__DEFAULT__") do
    case Repo.one(find_tag_query(oid, key, category)) do
      nil -> {:ok, false}
      _object -> {:ok, true}
    end
  end
  
  def list(tags) do
    Exmud.GameObject.list(tags: List.wrap(tags))
  end
  
  def remove(oid, key, category \\ "__DEFAULT__") do
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
  
  
  defp find_tag_query(oid, key, category) do
    from object in GameObject,
      left_join: tag in assoc(object, :tags), on: object.id == tag.oid,
      where: tag.key == ^key and tag.category == ^category and object.id == ^oid
  end
end