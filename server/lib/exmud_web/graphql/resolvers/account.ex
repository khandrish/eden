defmodule ExmudWeb.Graphql.Resolvers.Account do
  @spec create_player(any, map, any) :: {:error, String.t()} | {:ok, any}
  def create_player(_parent, args, _resolution) do
    case Exmud.Account.register_player(args.params) do
      {:ok, player} ->
        {:ok, player}

      {:error, changeset} ->
        {:error, Enum.join(ExmudWeb.Util.pretty_errors(changeset.errors), ", ")}
    end
  end

  @spec get_player(any, %{id: any}, any) :: {:error, String.t()} | {:ok, any}
  def get_player(_parent, %{id: id}, _resolution) do
    case Exmud.Account.get_player(id) do
      {:ok, player} ->
        {:ok, player}

      {:error, :not_found} ->
        {:error, "Player ID #{id} not found"}
    end
  end

  @spec list_players(any, any, any) :: {:ok, any}
  def list_players(_parent, %{page: page, page_size: page_size}, _resolution) do
    Exmud.Account.list_players(page, page_size)
  end
end
