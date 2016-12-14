defmodule Exmud.Schema.Relationship do
  import Ecto.Changeset
  use Ecto.Schema
  
  schema "relationship" do
    field :relationship, :string
    belongs_to :subject_object, Exmud.Schema.GameObject, foreign_key: :subject
    belongs_to :object_object, Exmud.Schema.GameObject, foreign_key: :object
  end
  
  def changeset(location, params \\ %{}) do
    location
    |> cast(params, [:object, :relationship, :subject])
    |> validate_required([:object, :relationship, :subject])
    |> foreign_key_constraint(:oid)
  end
end