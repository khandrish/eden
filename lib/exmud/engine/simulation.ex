defmodule Exmud.Engine.Simulation do
  use Ecto.Schema
  import Ecto.Changeset

  @timestamps_opts [type: :utc_datetime_usec]

  schema "simulations" do
    field :name, :string
    field :status, :string, default: "stopped"
    has_many(:callbacks, Exmud.Engine.SimulationCallback)

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
