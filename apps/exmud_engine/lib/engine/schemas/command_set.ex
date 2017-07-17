defmodule Exmud.Engine.Schema.CommandSet do
  use Exmud.Common.Schema

  schema "command_set" do
    field :command_set, :binary
    belongs_to :object, Exmud.Engine.Schema.Object, foreign_key: :object_id
    timestamps()
  end

  def add(tag, params \\ %{}) do
    tag
    |> cast(params, [:command_set, :object_id])
    |> validate_required([:command_set, :object_id])
    |> foreign_key_constraint(:object_id)
  end
end