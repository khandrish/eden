defmodule Exmud.DB.Object do
  import Ecto.Changeset
  use Ecto.Schema

  schema "object" do
    field :key, :string
    field :date_created, :utc_datetime
    has_many :callbacks, Exmud.Schema.Callback, foreign_key: :oid
    has_many :command_sets, Exmud.Schema.CommandSet, foreign_key: :oid
    has_many :components, Exmud.Schema.Component, foreign_key: :oid
    has_many :locks, Exmud.Schema.Lock, foreign_key: :oid
    has_many :relationships, Exmud.Schema.Relationship, foreign_key: :object
    has_many :scripts, Exmud.Schema.Script, foreign_key: :oid
    has_many :tags, Exmud.Schema.Tag, foreign_key: :oid
  end

  def changeset(object, params \\ %{}) do
    object
    |> cast(params, [:date_created, :key])
    |> validate_required([:date_created, :key])
  end
end