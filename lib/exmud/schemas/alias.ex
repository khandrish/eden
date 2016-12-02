defmodule Exmud.Schema.Alias do
  import Ecto.Changeset
  use Ecto.Schema
  
  schema "alias" do
    field :alias, :string
    belongs_to :game_object, Exmud.Schema.GameObject
  end
  
  def changeset(al, params \\ %{}) do
    al
    |> cast(params, [:game_object_id, :alias])
    |> validate_required([:game_object_id, :alias])
  end
end