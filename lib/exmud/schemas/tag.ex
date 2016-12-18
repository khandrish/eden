defmodule Exmud.Schema.Tag do
  import Ecto.Changeset
  use Ecto.Schema
  
  schema "tag" do
    field :key, :string
    field :category, :string
    belongs_to :game_object, Exmud.Schema.GameObject, foreign_key: :oid
  end
  
  def changeset(tag, params \\ %{}) do
    tag
    |> cast(params, [:category, :oid, :key])
    |> validate_required([:category, :oid, :key])
    |> foreign_key_constraint(:oid)
  end
end