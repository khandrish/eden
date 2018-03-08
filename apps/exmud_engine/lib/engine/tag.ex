defmodule Exmud.Engine.Tag do
  alias Exmud.Engine.Repo
  alias Exmud.Engine.Schema.Tag
  import Ecto.Query
  import Exmud.Common.Utils
  require Logger


  #
  # API
  #


  def attach(object_id, category, tag) do
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
          Logger.error("Attempt to add Tag onto non existing object `#{object_id}`")
          {:error, :no_such_object}
        else
          {:error, errors}
        end
      {:ok, _} ->
        :ok
    end
  end

  def is_attached?(object_id, category, tag) do
    query =
      from tag in tag_query(object_id, category, tag),
        select: count("*")

    Repo.one(query) == 1
  end

  def detach(object_id, category, tag) do
    tag_query(object_id, category, tag)
    |> Repo.delete_all()
    |> case do
      {num, _} when num > 0 -> :ok
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