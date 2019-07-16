defmodule Model.System do
  import Ecto.Changeset

  use Ecto.Schema

  schema "system" do
    field(:callback_module, Model.Type.CallbackModule)
    field(:state, :map, default: %{})

    timestamps()
  end

  def new(params) when is_map(params) do
    %__MODULE__{}
    |> cast(params, [:callback_module, :state])
    |> validate_required([:callback_module, :state])
  end

  def update(system, params) when is_map(params) do
    system
    |> cast(params, [:state])
    |> Model.Validations.validate_map(:state)
  end
end
