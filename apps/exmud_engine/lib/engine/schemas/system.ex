defmodule Exmud.Engine.Schema.System do
  use Exmud.Common.Schema

  schema "system" do
    field :callback_module, :any, virtual: true
    field :key, :string
    field :options, :binary
    field :state, :binary
  end

  def new(player, params \\ %{}) do
    player
    |> cast(params, [:key, :options, :state])
    |> validate_required([:key, :options, :state])
    |> unique_constraint(:key, [message: :key_in_use])
  end

  def update(player, params \\ %{}) do
    player
    |> cast(params, [:key, :options, :state])
    |> unique_constraint(:key, [message: :key_in_use])
  end
end