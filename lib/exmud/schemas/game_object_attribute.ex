defmodule Exmud.Schema.GameObjectAttribute do
  import Ecto.Changeset
  use Ecto.Schema
  
  schema "attribute" do
    field :name, :string
    field :data, :binary
    belongs_to :game_object, Exmud.Schema.GameObject
  end
  
  def changeset(attribute, params \\ %{}) do
    attribute
    |> cast(params, [:name, :data, :game_object_id])
    |> validate_required([:name, :data, :game_object_id])
  end
end