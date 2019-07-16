defmodule Exmud.Engine.Simulation do
  use Ecto.Schema
  import Ecto.Changeset

  schema "simulations" do
    field :name, :string
    field :status, :string

    timestamps()
  end

  @doc false
  def changeset(simulation, attrs) do
    simulation
    |> cast(attrs, [:name, :status])
    |> validate_required([:name, :status])
    |> unique_constraint(:name)
  end
end
