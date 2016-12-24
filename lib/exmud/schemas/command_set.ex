defmodule Exmud.Schema.CommandSet do
  import Ecto.Changeset
  use Ecto.Schema
  
  schema "command_set" do
    field :key, :string
    belongs_to :object, Exmud.Schema.Object, foreign_key: :oid
  end
  
  def changeset(tag, params \\ %{}) do
    tag
    |> cast(params, [:key, :oid])
    |> validate_required([:key, :oid])
    |> foreign_key_constraint(:oid)
  end
end