defmodule Exmud.Schema.Script do
  import Ecto.Changeset
  use Ecto.Schema
  
  schema "script" do
    field :key, :string
    field :state, :binary
    belongs_to :game_object, Exmud.Schema.GameObject, foreign_key: :oid
  end
  
  def changeset(script, params \\ %{}) do
    script
    |> cast(params, [:state, :key, :oid])
    |> validate_required([:state, :key, :oid])
  end
end