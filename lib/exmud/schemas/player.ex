defmodule Exmud.Schema.Player do
  import Ecto.Changeset
  use Ecto.Schema
  
  schema "player" do
    field :key, :string
    has_many :player_command_set, Exmud.Schema.PlayerCommandSet
    has_many :player_data, Exmud.Schema.PlayerData
  end
  
  def changeset(player, params \\ %{}) do
    player
    |> cast(params, [:key])
    |> validate_required([:key])
    |> unique_constraint(:key, [message: :key_in_use])
  end
end