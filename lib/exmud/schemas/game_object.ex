defmodule Exmud.Schema.GameObject do
  import Ecto.Changeset
  use Ecto.Schema
  
  schema "game_object" do
    field :key, :string
    field :date_created, Ecto.DateTime
    has_many :attributes, Exmud.Schema.Attribute, foreign_key: :oid
    has_many :callbacks, Exmud.Schema.Attribute, foreign_key: :oid
    has_many :command_sets, Exmud.Schema.Attribute, foreign_key: :oid
    has_many :locks, Exmud.Schema.Lock, foreign_key: :oid
    has_many :relationships, Exmud.Schema.Tag, foreign_key: :oid
    has_many :scripts, Exmud.Schema.Tag, foreign_key: :oid
    has_many :tags, Exmud.Schema.Tag, foreign_key: :oid
  end
  
  def changeset(object, params \\ %{}) do
    object
    |> cast(params, [:date_created, :key])
    |> validate_required([:date_created, :key])
  end
end