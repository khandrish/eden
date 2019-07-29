defmodule Exmud.Engine.SimulationCallback do
  use Ecto.Schema
  import Ecto.Changeset

  @timestamps_opts [type: :utc_datetime_usec]

  schema "simulation_callbacks" do
    field :default_config, :map
    belongs_to :simulation, Exmud.Engine.Simulation
    belongs_to :callback, Exmud.Engine.Callback

    timestamps()
  end

  @doc false
  def changeset(simulation_callback, attrs) do
    simulation_callback
    |> cast(attrs, [:default_config, :simulation_id, :callback_id])
    |> validate_required([:default_config])
  end
end
