defmodule Exmud.Schema.CommandSet do
  import Ecto.Changeset
  use Ecto.Schema

  schema "command_set" do
    field :module, :binary
    belongs_to :object, Exmud.Schema.Object, foreign_key: :oid
  end

  def changeset(tag, params \\ %{}) do
    tag
    |> cast(params, [:module, :oid])
    |> validate_required([:module, :oid])
    |> foreign_key_constraint(:oid)
  end
end
