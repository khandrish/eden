defmodule Exmud.Schema.GameObject do
  import Ecto.Changeset
  use Ecto.Schema
  
  schema "game_object" do
    field :key, :string
    field :date_created, Ecto.DateTime
    has_one :location, Exmud.Schema.GameObject
    has_one :home, Exmud.Schema.GameObject
    has_many :aliases, Exmud.Schema.Alias
    has_many :locks, Exmud.Schema.Lock
    has_many :tags, Exmud.Schema.Tag
    has_many :attributes, Exmud.Schema.GameObjectAttribute
  end
  
  def changeset(object, params \\ %{}) do
    object
    |> cast(params, [:date_created, :key])
    |> validate_required([:date_created, :key])
  end
end