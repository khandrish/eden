defmodule Exmud.Schema.Callback do
  import Ecto.Changeset
  use Ecto.Schema
  
  schema "callback" do
    field :callback, :string
    field :key, :string
    belongs_to :object, Exmud.Schema.Object, foreign_key: :oid
  end
  
  def changeset(tag, params \\ %{}) do
    tag
    |> cast(params, [:callback, :key, :oid])
    |> validate_required([:callback, :key, :oid])
    |> foreign_key_constraint(:oid)
  end
end