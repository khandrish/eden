defmodule Exmud.Engine.Schema.System do
  use Exmud.Common.Schema

  schema "system" do
    field :callback_module, :binary, virtual: true
    field :name, :string
    field :state, :binary
  end

  def cast(system), do: cast(system, %{}, [])

  def new(system, params \\ %{}) do
    system
    |> cast(params, [:name, :state])
    |> validate_required([:name, :state])
    |> unique_constraint(:name, [message: :key_in_use])
  end

  def update(system, params \\ %{}) do
    system
    |> cast(params, [:name, :state])
    |> unique_constraint(:name, [message: :key_in_use])
  end
end