defmodule ExmudWeb.Graphql.Types.Account do
  use Absinthe.Schema.Notation

  @desc "A player"
  object :player do
    field :id, non_null(:id)
    field :status, non_null(:string)
    field :profile, non_null(:profile)
    field :inserted_at, non_null(:datetime)
    field :updated_at, non_null(:datetime)
  end

  @desc "A profile for a player"
  object :profile do
    field :id, non_null(:id)
    field :nickname, non_null(:string)
    field :email, non_null(:string)
    field :inserted_at, non_null(:datetime)
    field :updated_at, non_null(:datetime)
  end
end
