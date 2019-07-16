defmodule Model.Simulation do
  import Ecto.Changeset

  use Ecto.Schema

  schema "simulation" do
    field(:callback_module, Model.Type.CallbackModule)
    field(:prefix, :string)
    field(:state, :map, default: %{})

    timestamps()
  end

  def new(params) when is_map(params) do
    %__MODULE__{}
    |> cast(params, [:callback_module, :prefix, :state])
    |> validate_required([:callback_module, :prefix, :state])
  end

  def update(simulation, params) when is_map(params) do
    simulation
    |> cast(params, [:callback_module, :prefix, :state])
    |> Model.Validations.validate_map(:state)
  end
end
