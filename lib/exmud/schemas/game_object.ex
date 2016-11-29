defmodule Exmud.Schema.GameObject do
  use Ecto.Schema
  
  schema "game_object" do
    field :key, :string
    field :date_created, Ecto.DateTime
    field :type, :string
    has_one :location, Exmud.Schema.GameObject
    has_one :home, Exmud.Schema.GameObject
    has_many :aliases, Exmud.Schema.Alias
    has_many :locks, Exmud.Schema.Lock
    has_many :tags, Exmud.Schema.Tag
    has_many :game_object_data, Exmud.Schema.GameObjectData
  end
end