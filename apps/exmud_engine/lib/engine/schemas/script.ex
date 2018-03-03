defmodule Exmud.Engine.Schema.Script do
  use Exmud.Common.Schema

  schema "script" do
    field :callback_module, :any, virtual: true
    field :deserialized_state, :any, virtual: true
    field :name, :string
    field :state, :binary
    belongs_to :object, Exmud.Engine.Schema.Object, foreign_key: :object_id
  end

  def load(script, params) do
    script
    |> cast(params, [:callback_module, :deserialized_state])
  end

  def new(params) do
    %Exmud.Engine.Schema.Script{}
    |> cast(params, [:name, :object_id, :state, :callback_module, :deserialized_state])
    |> validate_required([:name, :object_id])
    |> foreign_key_constraint(:object_id)
  end
end