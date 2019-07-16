defmodule Model.Script do
  import Ecto.Changeset

  use Ecto.Schema

  schema "script" do
    field(:callback_module, Model.Type.CallbackModule)
    field(:state, :map, default: %{})
    belongs_to(:object, Model.Object, foreign_key: :object_id)

    timestamps()
  end

  def new(params) when is_map(params) do
    %__MODULE__{}
    |> cast(params, [:callback_module, :object_id, :state])
    |> validate_required([:callback_module, :object_id, :state])
    |> foreign_key_constraint(:object_id)
  end

  def update(script, params) when is_map(params) do
    script
    |> cast(params, [:state])
    |> Model.Validations.validate_map(:state)
  end
end
