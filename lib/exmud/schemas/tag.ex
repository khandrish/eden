defmodule Exmud.Schema.Tag do
  use Ecto.Schema
  
  schema "tag" do
    field :tag, :string
    belongs_to :game_object, Exmud.Schema.GameObject
  end
end