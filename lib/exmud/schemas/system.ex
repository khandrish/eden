defmodule Exmud.Schema.System do
  import Ecto.Changeset
  use Ecto.Schema

  schema "system" do
    field :key, :string
    field :state, :binary
  end

  def changeset(player, params \\ %{}) do
    player
    |> cast(params, [:key, :state])
    |> validate_required([:key, :state])
    |> unique_constraint(:key, [message: :key_in_use])
  end
end
