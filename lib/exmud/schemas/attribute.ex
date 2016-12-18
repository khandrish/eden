defmodule Exmud.Schema.Attribute do
  import Ecto.Changeset
  use Ecto.Schema
  
  schema "attribute" do
    field :key, :string
    field :data, :binary
    belongs_to :game_object, Exmud.Schema.GameObject, foreign_key: :oid
  end
  
  def changeset(attribute, params \\ %{}) do
    attribute
    |> cast(params, [:data, :key, :oid])
    |> validate_required([:data, :key, :oid])
    |> foreign_key_constraint(:oid)
  end
end