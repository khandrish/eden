defmodule Exmud.DB.Attribute do
  use Exmud.DB.Model

  schema "attribute" do
    field :attribute, :string
    field :data, :binary
    belongs_to :component, Exmud.DB.Component, foreign_key: :component_id
  end

  def changeset(attribute, params \\ %{}) do
    attribute
    |> cast(params, [:data, :attribute])
    |> validate_required([:data, :attribute])
    |> foreign_key_constraint(:component_id)
  end
end