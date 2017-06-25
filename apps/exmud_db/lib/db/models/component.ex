defmodule Exmud.DB.Component do
  import Ecto.Changeset
  use Ecto.Schema

  schema "component" do
    field :component, :binary
    belongs_to :object, Exmud.Schema.Object, foreign_key: :oid
    has_many :data, Exmud.Schema.Attribute, foreign_key: :component_id
  end

  def changeset(component, params \\ %{}) do
    component
    |> cast(params, [:component, :oid])
    |> validate_required([:component, :oid])
    |> foreign_key_constraint(:oid)
  end

  def add_data_changeset(component, params \\ %{}) do
    component
    |> cast(params, [:attribute, :data])
    |> validate_required([:attribute, :data])
    |> cast_assoc(:data)
  end
end