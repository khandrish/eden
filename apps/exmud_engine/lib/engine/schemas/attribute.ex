defmodule Exmud.Engine.Schema.Attribute do
  use Exmud.Common.Schema

  schema "attribute" do
    field :attribute, :string
    field :data, :binary
    belongs_to :component, Exmud.Engine.Schema.Component, foreign_key: :component_id
  end

  def update(attribute, params \\ %{}) do
    attribute
    |> cast(params, [:data, :attribute])
    |> validate_required([:data, :attribute])
    |> foreign_key_constraint(:component_id)
  end
end