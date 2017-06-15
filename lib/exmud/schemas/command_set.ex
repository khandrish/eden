defmodule Exmud.Schema.CommandSet do
  import Ecto.Changeset
  use Ecto.Schema

  schema "command_set" do
    field :callback_module, :binary
    belongs_to :object, Exmud.Schema.Object, foreign_key: :oid
    timestamps
  end

  def changeset(tag, params \\ %{}) do
    tag
    |> cast(params, [:callback_module, :oid])
    |> validate_required([:callback_module, :oid])
    |> foreign_key_constraint(:oid)
  end
end
