defmodule Exmud.DB.Model.Object do
  use Exmud.DB.Model

  schema "object" do
    field :key, :string
    field :date_created, :utc_datetime
    has_many :callbacks, Exmud.DB.Model.Callback, foreign_key: :oid
    has_many :command_sets, Exmud.DB.Model.CommandSet, foreign_key: :oid
    has_many :components, Exmud.DB.Model.Component, foreign_key: :oid
    has_many :locks, Exmud.DB.Model.Lock, foreign_key: :oid
    has_many :relationships, Exmud.DB.Model.Relationship, foreign_key: :object
    has_many :scripts, Exmud.DB.Model.Script, foreign_key: :oid
    has_many :tags, Exmud.DB.Model.Tag, foreign_key: :oid
  end

  def changeset(object, params \\ %{}) do
    object
    |> cast(params, [:date_created, :key])
    |> validate_required([:date_created, :key])
  end
end