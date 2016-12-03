defmodule Exmud.Schema.Location do
  import Ecto.Changeset
  use Ecto.Schema
  
  schema "location" do
    belongs_to :subject_game_object, Exmud.Schema.GameObject, foreign_key: :oid
    belongs_to :location_game_object, Exmud.Schema.GameObject, foreign_key: :location
  end
  
  def changeset(location, params \\ %{}) do
    location
    |> cast(params, [:location, :oid])
    |> validate_required([:location, :oid])
  end
end