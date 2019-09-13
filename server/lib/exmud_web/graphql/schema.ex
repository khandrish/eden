defmodule ExmudWeb.Graphql.Schema do
  use Absinthe.Schema

  import_types(Absinthe.Type.Custom)
  import_types(ExmudWeb.Graphql.Types.Account)
  import_types(ExmudWeb.Graphql.Types.Builder)

  alias ExmudWeb.Graphql.Resolvers

  query do
    @desc "List all players"
    field :list_players, list_of(:player) do
      arg(:page, non_null(:integer))
      arg(:page_size, non_null(:integer))

      resolve(&Resolvers.Account.list_players/3)
    end

    @desc "Get a player"
    field :get_player, :player do
      arg(:id, non_null(:id))

      resolve(&Resolvers.Account.get_player/3)
    end

    @desc "List all muds"
    field :list_muds, list_of(:mud) do
      resolve(&Resolvers.Builder.list_muds/3)
    end

    @desc "Get a mud"
    field :get_mud, :mud do
      arg(:id, non_null(:id))

      resolve(&Resolvers.Builder.get_mud/3)
    end
  end

  mutation do
    @desc "Register a player"
    field :register_player, :player do
      arg(:params, non_null(:register_player_input))

      resolve(&Resolvers.Account.create_player/3)
    end
  end

  input_object :register_player_input do
    field :nickname, non_null(:string)
    field :email, non_null(:string)
  end
end
