defmodule Exmud.DB.Relationship do
  use Exmud.DB.Model

  schema "relationship" do
    field :relationship, :string
    field :data, :binary
    belongs_to :subject_object, Exmud.DB.Object, foreign_key: :subject
    belongs_to :object_object, Exmud.DB.Object, foreign_key: :object
  end

  def changeset(location, params \\ %{}) do
    location
    |> cast(params, [:object, :relationship, :subject, :data])
    |> validate_required([:object, :relationship, :subject, :data])
    |> foreign_key_constraint(:object)
    |> foreign_key_constraint(:subject)
  end
end