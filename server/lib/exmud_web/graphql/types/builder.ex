defmodule ExmudWeb.Graphql.Types.Builder do
  use Absinthe.Schema.Notation

  @desc "A MUD"
  object :mud do
    field :id, non_null(:id)
    field :name, non_null(:string)
    field :created_at, non_null(:datetime)
  end
end
