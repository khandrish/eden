defmodule Exmud.Engine.Schema.System do
  use Exmud.Common.Schema

  schema "system" do
    field :callback_module, :binary, virtual: true
    field :initialized, :boolean, default: false, virtual: true
    field :key, :string
    field :last_checkpoint, :string
    field :running, :boolean, default: false
    field :state, :binary
  end

  def cast(system), do: cast(system, %{}, [])

  def new(system, params \\ %{}) do
    system
    |> cast(params, [:key, :running, :state])
    |> validate_required([:key, :state])
    |> unique_constraint(:key, [message: :key_in_use])
  end

  def update(system, params \\ %{}) do
    system
    |> cast(params, [:key, :running, :state])
    |> unique_constraint(:key, [message: :key_in_use])
  end
end