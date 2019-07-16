defmodule Exmud.Engine.SimulationCallback do
  use Ecto.Schema
  import Ecto.Changeset

  schema "simulation_callbacks" do
    field :default_args, :binary
    field :simulation_id, :id
    field :callback_id, :id

    timestamps()
  end

  @doc false
  def changeset(simulation_callback, attrs) do
    simulation_callback
    |> cast(attrs, [:default_args])
    |> validate_required([:default_args])
  end
end
