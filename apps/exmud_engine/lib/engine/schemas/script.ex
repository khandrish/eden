defmodule Exmud.Engine.Schema.Script do
  use Exmud.Common.Schema

  schema "script" do
    field :name, :string
    field :callback_module, :binary
    field :state, :binary
    belongs_to :object, Exmud.Engine.Schema.Object, foreign_key: :object_id
  end

  def changeset(script, params \\ %{}) do
    script
    |> cast(params, [:state, :name, :object_id])
    |> validate_required([:state, :name, :object_id])
    |> foreign_key_constraint(:object_id)
  end
end