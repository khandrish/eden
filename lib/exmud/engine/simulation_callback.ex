defmodule Exmud.Engine.SimulationCallback do
  use Ecto.Schema
  import Ecto.Changeset

  @timestamps_opts [type: :utc_datetime_usec]

  schema "simulation_callbacks" do
    field :default_config, :map
    field :simulation_id, :id
    field :callback_id, :id

    timestamps()
  end

  @doc false
  def changeset(simulation_callback, attrs) do
    simulation_callback
    |> cast(attrs, [:default_config])
    |> validate_required([:default_config])
  end
end
