defmodule Model.Component do
  import Ecto.Changeset

  use Ecto.Schema

  schema "component" do
    field(:callback_module, Model.Type.CallbackModule)
    field(:data, :map, default: %{})
    belongs_to(:object, Model.Object, foreign_key: :object_id)

    timestamps()
  end

  def new(params) when is_map(params) do
    %__MODULE__{}
    |> cast(params, [:data, :callback_module, :object_id])
    |> validate_required([:callback_module, :object_id])
    |> foreign_key_constraint(:object_id)
    |> unique_constraint(:callback_module, name: :component_object_id_callback_module_index)
  end

  def update(component, params) when is_map(params) do
    component
    |> cast(params, [:data])
    |> Model.Validations.validate_map(:data)
  end
end
