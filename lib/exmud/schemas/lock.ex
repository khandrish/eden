defmodule Exmud.Schema.Lock do
  import Ecto.Changeset
  use Ecto.Schema

  schema "lock" do
    field :type, :string
    field :definition, :string
    belongs_to :object, Exmud.Schema.Object, foreign_key: :oid
  end

  def changeset(tag, params \\ %{}) do
    tag
    |> cast(params, [:definition, :oid, :type])
    |> validate_required([:definition, :oid, :type])
    |> foreign_key_constraint(:oid)
  end
end
