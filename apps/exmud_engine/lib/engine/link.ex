defmodule Exmud.Engine.Link do
  alias Exmud.Engine.Repo
  alias Exmud.Engine.Schema.Link
  import Exmud.Common.Utils
  import Exmud.Engine.Utils

  def forge(from, to, type, data \\ %{}) do
    %Link{}
    |> Link.new(%{from_id: from, to_id: to, type: type, data: pack_term(data)})
    |> Repo.insert()
    |> normalize_repo_result(from)
    |> case do
      {:ok, _} -> :ok
      error -> error
    end
  end
end