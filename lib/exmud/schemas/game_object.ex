defmodule Exmud.Schema.GameObject do
  import Ecto.Changeset
  use Ecto.Schema
  
  schema "game_object" do
    field :key, :string
    field :date_created, Ecto.DateTime
    has_many :location, Exmud.Schema.Location, foreign_key: :oid
    has_many :home, Exmud.Schema.Home, foreign_key: :oid
    has_many :aliases, Exmud.Schema.Alias, foreign_key: :oid
    has_many :locks, Exmud.Schema.Lock, foreign_key: :oid
    has_many :tags, Exmud.Schema.Tag, foreign_key: :oid
    has_many :attributes, Exmud.Schema.Attribute, foreign_key: :oid
  end
  
  def changeset(object, params \\ %{}) do
    object
    |> cast(params, [:date_created, :key])
    |> validate_required([:date_created, :key])
  end
end