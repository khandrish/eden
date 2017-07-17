defmodule Exmud.Engine.Schema.Object do
  use Exmud.Common.Schema

  schema "object" do
    field :key, :string
    field :date_created, :utc_datetime
    has_many :callbacks, Exmud.Engine.Schema.Callback, foreign_key: :object_id
    has_many :command_sets, Exmud.Engine.Schema.CommandSet, foreign_key: :object_id
    has_many :components, Exmud.Engine.Schema.Component, foreign_key: :object_id
    has_many :locks, Exmud.Engine.Schema.Lock, foreign_key: :object_id
    has_many :relationships, Exmud.Engine.Schema.Relationship, foreign_key: :from_id
    has_many :scripts, Exmud.Engine.Schema.Script, foreign_key: :object_id
    has_many :tags, Exmud.Engine.Schema.Tag, foreign_key: :object_id
  end

  def new(object, params \\ %{}) do
    object
    |> cast(params, [:key])
    |> put_change(:date_created, DateTime.utc_now())
    |> validate_required([:date_created, :key])
  end
end