defmodule Exmud.Schema.Callback do
  import Ecto.Changeset
  use Ecto.Schema

  schema "callback" do
    field :string, :string
    field :module, :binary
    belongs_to :object, Exmud.Schema.Object, foreign_key: :oid
  end

  def changeset(tag, params \\ %{}) do
    tag
    |> cast(params, [:string, :module, :oid])
    |> validate_required([:string, :module, :oid])
    |> foreign_key_constraint(:oid)
  end
end
