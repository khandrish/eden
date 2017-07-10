defmodule Exmud.Engine.Schema.System do
  use Exmud.Common.Schema

  schema "system" do
    field :key, :string
    field :state, :binary
  end

  def new(player, params \\ %{}) do
    player
    |> cast(params, [:key, :state])
    |> validate_required([:key, :state])
    |> unique_constraint(:key, [message: :key_in_use])
  end

  def update(player, params \\ %{}) do
    player
    |> cast(params, [:key, :state])
    |> unique_constraint(:key, [message: :key_in_use])
  end
end