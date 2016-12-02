defmodule Exmud.Schema.Tag do
  import Ecto.Changeset
  use Ecto.Schema
  
  schema "tag" do
    field :tag, :string
    belongs_to :game_object, Exmud.Schema.GameObject
  end
  
  def changeset(tag, params \\ %{}) do
    tag
    |> cast(params, [:game_object_id, :tag])
    |> validate_required([:game_object_id, :tag])
  end
end