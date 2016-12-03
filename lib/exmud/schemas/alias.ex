defmodule Exmud.Schema.Alias do
  import Ecto.Changeset
  use Ecto.Schema
  
  schema "alias" do
    field :alias, :string
    belongs_to :game_object, Exmud.Schema.GameObject, foreign_key: :oid
  end
  
  def changeset(al, params \\ %{}) do
    al
    |> cast(params, [:alias, :oid])
    |> validate_required([:alias, :oid])
  end
end