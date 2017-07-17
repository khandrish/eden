defmodule Exmud.Engine.Schema.Relationship do
  use Exmud.Common.Schema

  schema "relationship" do
    field :relationship, :string
    field :data, :binary
    belongs_to :to, Exmud.Engine.Schema.Object, foreign_key: :to_id
    belongs_to :from, Exmud.Engine.Schema.Object, foreign_key: :from_id
  end

  def add(relationship, params \\ %{}) do
    relationship
    |> cast(params, [:data, :from_id, :relationship, :to_id])
    |> validate_required([:data, :from_id, :relationship, :to_id])
    |> foreign_key_constraint(:to_id)
    |> foreign_key_constraint(:from_id)
  end

  def update(relationship, params \\ %{}) do
    relationship
    |> cast(params, [:relationship, :data])
  end
end