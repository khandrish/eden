defmodule Exmud.Schema.PlayerData do
  import Ecto.Changeset
  use Ecto.Schema
  
  schema "player_data" do
    field :key, :string
    field :value, :binary
    
    belongs_to :player, Exmud.Schema.Player
  end
  
  def changeset(player, params \\ %{}) do
    player
    |> cast(params, [:key, :value, :player_id])
    |> validate_required([:key, :value, :player_id])
  end
end