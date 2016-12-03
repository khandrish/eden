defmodule Exmud.Schema.Home do
  import Ecto.Changeset
  use Ecto.Schema
  
  schema "home" do
    belongs_to :subject_game_object, Exmud.Schema.GameObject, foreign_key: :oid
    belongs_to :home_game_object, Exmud.Schema.GameObject, foreign_key: :home
  end
  
  def changeset(home, params \\ %{}) do
    home
    |> cast(params, [:home, :oid])
    |> validate_required([:home, :oid])
  end
end