defmodule Exmud.DB.Model.Tag do
  use Exmud.DB.Model

  schema "tag" do
    field :key, :string
    field :category, :string
    belongs_to :object, Exmud.DB.Model.Object, foreign_key: :oid
  end

  def changeset(tag, params \\ %{}) do
    tag
    |> cast(params, [:category, :oid, :key])
    |> validate_required([:category, :oid, :key])
    |> foreign_key_constraint(:oid)
  end
end