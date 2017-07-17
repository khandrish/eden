defmodule Exmud.Engine.Relationship do
  alias Exmud.Engine.Repo
  alias Exmud.Engine.Schema.Relationship
  import Exmud.Common.Utils

  def add(from, to, relationship, data \\ %{}) do
    %Relationship{}
    |> Relationship.add(%{from_id: from, to_id: to, relationship: relationship, data: serialize(data)})
    |> Repo.insert()
    |> normalize_repo_result(from)
  end
end