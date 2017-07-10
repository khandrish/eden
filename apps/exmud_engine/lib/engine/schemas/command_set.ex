defmodule Exmud.Engine.Schema.CommandSet do
  use Exmud.Common.Schema

  schema "command_set" do
    field :callback_module, :binary
    belongs_to :object, Exmud.Engine.Schema.Object, foreign_key: :object_id
    timestamps()
  end

  def add(tag, params \\ %{}) do
    tag
    |> cast(params, [:callback_module, :object_id])
    |> validate_required([:callback_module, :object_id])
    |> foreign_key_constraint(:object_id)
  end
end