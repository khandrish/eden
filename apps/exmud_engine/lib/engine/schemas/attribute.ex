defmodule Exmud.Engine.Schema.Attribute do
  use Exmud.Common.Schema

  schema "attribute" do
    field(:name, :string)
    field(:value, :binary)
    belongs_to(:component, Exmud.Engine.Schema.Component, foreign_key: :component_id)
  end

  def new(params) do
    %Exmud.Engine.Schema.Attribute{}
    |> cast(params, [:value, :name])
    |> validate_required([:value, :name])
    |> foreign_key_constraint(:component_id)
    |> unique_constraint(:name, name: :attribute_component_id_name_index)
  end
end
