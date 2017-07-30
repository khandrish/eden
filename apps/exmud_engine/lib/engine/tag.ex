defmodule Exmud.Engine.Tag do
  alias Exmud.Engine.Repo
  alias Exmud.Engine.Schema.Tag
  import Ecto.Query
  import Exmud.Common.Utils
  require Logger


  #
  # API
  #


  def add(object_id, category, tag) do
    args = %{category: category,
             object_id: object_id,
             tag: tag}

    %Tag{}
    |> Tag.add(args)
    |> Repo.insert()
    |> normalize_repo_result(object_id)
    |> case do
      {:error, errors} ->
        if Keyword.has_key?(errors, :object_id) do
          Logger.warn("Attempt to add tag onto non existing object `#{object_id}`")
          {:error, :no_such_object}
        else
          {:error, errors}
        end
      result ->
        result
    end
  end

  def has(object_id, category, tag) do
    case Repo.one(tag_query(object_id, category, tag)) do
      nil -> {:ok, false}
      _object -> {:ok, true}
    end
  end

  def remove(object_id, category, tag) do
    tag_query(object_id, category, tag)
    |> Repo.delete_all()
    |> case do
      {num, _} when num > 0 -> {:ok, object_id}
      {0, _} -> {:error, :no_such_tag}
      _ -> {:error, :unknown}
    end
  end


  #
  # Private functions
  #


  defp tag_query(object_id, category, tag) do
    from tag in Tag,
      where: tag.category == ^category
        and tag.tag == ^tag
        and tag.object_id == ^object_id
  end
end