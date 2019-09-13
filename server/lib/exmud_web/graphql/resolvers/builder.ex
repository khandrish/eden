defmodule ExmudWeb.Graphql.Resolvers.Builder do
  @spec get_mud(any, %{id: any}, any) :: {:error, String.t()} | {:ok, any}
  def get_mud(_parent, %{id: id}, _resolution) do
    case Exmud.Builder.get_mud(id) do
      {:ok, mud} ->
        {:ok, mud}

      {:error, :not_found} ->
        {:error, "MUD ID #{id} not found"}
    end
  end

  @spec list_muds(any, any, any) :: {:ok, any}
  def list_muds(_parent, _args, _resolution) do
    Exmud.Builder.list_muds()
  end
end
