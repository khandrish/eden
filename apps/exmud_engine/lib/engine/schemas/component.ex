defmodule Exmud.Engine.Schema.Component do
  use Exmud.Common.Schema

  schema "component" do
    field :component, :binary
    belongs_to :object, Exmud.Engine.Schema.Object, foreign_key: :object_id
    has_many :attributes, Exmud.Engine.Schema.Attribute, foreign_key: :component_id
  end

  def add(component, params \\ %{}) do
    component
    |> cast(params, [:component, :object_id])
    |> validate_required([:component, :object_id])
    |> foreign_key_constraint(:object_id)
  end
end