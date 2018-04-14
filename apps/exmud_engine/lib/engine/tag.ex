defmodule Exmud.Engine.Tag do
  @moduledoc """
  Tags either exist on an Object, each belonging to a Category/Namespace, or they do not. They have no data associted
  with them other than their existence.
  """

  alias Exmud.Engine.Repo
  alias Exmud.Engine.Schema.Tag
  import Ecto.Query
  import Exmud.Common.Utils
  require Logger

  @typedoc "The Category that the Tag belongs to."
  @type category :: String.t

  @typedoc "The Object that the Tag belongs to."
  @type object_id :: integer

  @typedoc "Id of the Object the Script is attached to."
  @type tag :: String.t


  #
  # API
  #


  @doc """
  Attach a Tag to an Object.
  """
  @spec attach(object_id, category, tag) :: :ok | {:error, :unable_to_attach_tag}
  def attach(object_id, category, tag) do
    args = %{category: category,
             object_id: object_id,
             tag: tag}

    %Tag{}
    |> Tag.add(args)
    |> Repo.insert()
    |> normalize_repo_result(object_id)
    |> case do
      {:ok, _} -> :ok
      _ -> {:error, :unable_to_attach_tag}
    end
  end

  @doc """
  Check to see if a Tag is attached to an Object.
  """
  @spec is_attached?(object_id, category, tag) :: boolean
  def is_attached?(object_id, category, tag) do
    query =
      from tag in tag_query(object_id, category, tag),
        select: count("*")

    Repo.one(query) == 1
  end

  @doc """
  Detach a Tag from an Object.
  """
  @spec detach(object_id, category, tag) :: :ok | {:error, :no_such_tag}
  def detach(object_id, category, tag) do
    tag_query(object_id, category, tag)
    |> Repo.delete_all()
    |> case do
      {num, _} when num > 0 -> :ok
      {0, _} -> {:error, :no_such_tag}
    end
  end


  #
  # Private functions
  #


  @spec tag_query(object_id, category, tag) :: term
  defp tag_query(object_id, category, tag) do
    from tag in Tag,
      where: tag.category == ^category
        and tag.tag == ^tag
        and tag.object_id == ^object_id
  end
end