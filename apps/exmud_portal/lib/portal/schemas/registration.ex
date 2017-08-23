defmodule Exmud.Portal.Schema.Registration do
  use Exmud.Common.Schema

  @required_fields ~w(email login password nickname)

  embedded_schema do
    field :email, :string
    field :login, :string
    field :password, :string
    field :nickname, :string
  end

  def register(params) do
    %Registration{}
    |> Ecto.Changeset.cast(params, @required_fields)
    |> validate_required(@required_fields)
    |> validate_length(:login, min: 8, max: 256)
    |> validate_length(:password, min: 8, max: 72)
  end
end