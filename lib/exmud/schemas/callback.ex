defmodule Exmud.Schema.Callback do
  import Ecto.Changeset
  use Ecto.Schema
  
  schema "callback" do
    field :key, :string
    belongs_to :game_object, Exmud.Schema.GameObject, foreign_key: :oid
  end
  
  def changeset(tag, params \\ %{}) do
    tag
    |> cast(params, [:key, :oid])
    |> validate_required([:key, :oid])
  end
end