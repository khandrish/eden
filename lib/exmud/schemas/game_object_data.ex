defmodule Exmud.Schema.GameObjectData do
  use Ecto.Schema
  
  schema "game_object_data" do
    field :key, :string
    field :value, :binary
    belongs_to :game_object, Exmud.Schema.GameObject
  end
end