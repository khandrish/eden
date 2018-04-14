defmodule Exmud.Engine.Schema.Attribute do
  use Exmud.Common.Schema

  schema "attribute" do
    field :name, :string
    field :value, :binary
    belongs_to :component, Exmud.Engine.Schema.Component, foreign_key: :component_id
  end

  def update(attribute, params \\ %{}) do
    attribute
    |> cast(params, [:value, :name])
    |> validate_required([:value, :name])
    |> foreign_key_constraint(:component_id)
  end
end