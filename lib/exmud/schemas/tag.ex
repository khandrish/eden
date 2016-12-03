defmodule Exmud.Schema.Tag do
  import Ecto.Changeset
  use Ecto.Schema
  
  schema "tag" do
    field :tag, :string
    belongs_to :game_object, Exmud.Schema.GameObject, foreign_key: :oid
  end
  
  def changeset(tag, params \\ %{}) do
    tag
    |> cast(params, [:oid, :tag])
    |> validate_required([:oid, :tag])
  end
end