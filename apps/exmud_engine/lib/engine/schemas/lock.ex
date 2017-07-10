defmodule Exmud.Engine.Schema.Lock do
  use Exmud.Common.Schema

  schema "lock" do
    field :type, :string
    field :definition, :string
    belongs_to :object, Exmud.Engine.Schema.Object, foreign_key: :object_id
  end

  def changeset(tag, params \\ %{}) do
    tag
    |> cast(params, [:definition, :object_id, :type])
    |> validate_required([:definition, :object_id, :type])
    |> foreign_key_constraint(:object_id)
  end
end