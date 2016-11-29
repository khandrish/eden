defmodule Exmud.Schema.System do
  import Ecto.Changeset
  use Ecto.Schema
  
  schema "system" do
    field :key, :string
    field :callback, :binary
    field :state, :binary
  end
  
  def changeset(player, params \\ %{}) do
    player
    |> cast(params, [:key, :state, :callback])
    |> validate_required([:key, :state, :callback])
    |> unique_constraint(:key, [message: :key_in_use])
  end
end