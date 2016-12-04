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
  
  def add(oid, tag, category \\ "__DEFAULT__") do
    args = %{category: category,
             date_created: Ecto.DateTime.utc(),
             oid: oid,
             tag: tag}
    Repo.insert(Tag.changeset(%Tag{}, args))
    |> normalize_noreturn_result()
  end
  
  def has?(oid, tag, category \\ "__DEFAULT__") do
    case Repo.one(find_tag_query(oid, tag, category)) do
      nil -> {:error, :no_such_game_object}
      object ->
        length =
          object.tags
          |> filter(category)
          |> length()
        filter(object.tags, category)
        {:ok, length > 0}
    end
  end
  
  def remove(oid, tag, category \\ "__DEFAULT__") do
    Repo.delete_all(
      from tag in Tag,
        where: tag.oid == ^oid,
        where: tag.tag == ^tag,
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

  
  defp filter([], _, results), do: results
  
  defp filter([tag|tags], category, results) do
    if tag.category == category do
      filter(tags, category, [tag|results])
    else
      filter(tags, category, results)
    end
  end
  
  defp filter(tags, category, results \\ []) do
    filter(tags, category, results)
  end
  
  
  defp find_tag_query(oid, tag, category) do
    from object in GameObject,
      left_join: tag in assoc(object, :tags), on: object.id == tag.oid,
      where: object.id == ^oid or tag.tag == ^tag and object.id == ^oid,
      preload: [tags: tag]
  end
end