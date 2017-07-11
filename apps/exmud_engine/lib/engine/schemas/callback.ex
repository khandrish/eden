defmodule Exmud.Engine.Schema.Callback do
  use Exmud.Common.Schema

  schema "callback" do
    field :string, :string
    field :callback_module, :binary
    belongs_to :object, Exmud.Engine.Schema.Object, foreign_key: :object_id
  end

  def add(callback, params \\ %{}) do
    callback
    |> cast(params, [:string, :callback_module, :object_id])
    |> validate_required([:string, :callback_module, :object_id])
    |> foreign_key_constraint(:object_id)
  end
end