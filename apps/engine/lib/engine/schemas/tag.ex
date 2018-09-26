defmodule Exmud.Engine.Schema.Tag do
  use Exmud.Common.Schema

  schema "tag" do
    field(:tag, :string)
    field(:category, :string)
    belongs_to(:object, Exmud.Engine.Schema.Object, foreign_key: :object_id)
  end

  def new(params) do
    %Exmud.Engine.Schema.Tag{}
    |> cast(params, [:category, :object_id, :tag])
    |> validate_required([:category, :object_id, :tag])
    |> foreign_key_constraint(:object_id)
  end
end
