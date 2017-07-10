defmodule Exmud.Engine.Schema.Relationship do
  use Exmud.Common.Schema

  schema "relationship" do
    field :relationship, :string
    field :data, :binary
    belongs_to :target, Exmud.Engine.Schema.Object, foreign_key: :target_id
    belongs_to :object, Exmud.Engine.Schema.Object, foreign_key: :object_id
  end

  def changeset(location, params \\ %{}) do
    location
    |> cast(params, [:object_id, :relationship, :target_id, :data])
    |> validate_required([:object_id, :relationship, :target_id, :data])
    |> foreign_key_constraint(:object_id)
    |> foreign_key_constraint(:target_id)
  end
end