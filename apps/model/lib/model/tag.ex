defmodule Model.Tag do
  import Ecto.Changeset

  use Ecto.Schema

  schema "tag" do
    field(:tag, :string)
    field(:category, :string)
    belongs_to(:object, Model.Object, foreign_key: :object_id)

    timestamps()
  end

  def new(params) when is_map(params) do
    %__MODULE__{}
    |> cast(params, [:category, :object_id, :tag])
    |> validate_required([:category, :object_id, :tag])
    |> foreign_key_constraint(:object_id)
  end
end
