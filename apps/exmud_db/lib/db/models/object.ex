defmodule Exmud.DB.Object do
  use Exmud.DB.Model

  schema "object" do
    field :key, :string
    field :date_created, :utc_datetime
    has_many :callbacks, Exmud.DB.Callback, foreign_key: :oid
    has_many :command_sets, Exmud.DB.CommandSet, foreign_key: :oid
    has_many :components, Exmud.DB.Component, foreign_key: :oid
    has_many :locks, Exmud.DB.Lock, foreign_key: :oid
    has_many :relationships, Exmud.DB.Relationship, foreign_key: :object
    has_many :scripts, Exmud.DB.Script, foreign_key: :oid
    has_many :tags, Exmud.DB.Tag, foreign_key: :oid
  end

  def changeset(object, params \\ %{}) do
    object
    |> cast(params, [:date_created, :key])
    |> validate_required([:date_created, :key])
  end
end