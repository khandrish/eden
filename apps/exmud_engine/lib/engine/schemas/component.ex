defmodule Exmud.Engine.Schema.Component do
  use Exmud.Common.Schema

  schema "component" do
    field :name, :string
    belongs_to :object, Exmud.Engine.Schema.Object, foreign_key: :object_id
    has_many :attributes, Exmud.Engine.Schema.Attribute, foreign_key: :component_id
  end

  def new(params) do
    %Exmud.Engine.Schema.Component{}
    |> cast(params, [:name, :object_id])
    |> validate_required([:name, :object_id])
    |> foreign_key_constraint(:object_id)
    |> unique_constraint(:name, name: :component_object_id_name_index)
  end
end