defmodule Exmud.Schema.Lock do
  use Ecto.Schema
  
  schema "lock" do
    field :type, :string
    field :definition, :string
    belongs_to :game_object, Exmud.Schema.GameObject
  end
end