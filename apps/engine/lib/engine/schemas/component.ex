defmodule Exmud.Engine.Schema.Component do
  use Exmud.Common.Schema

  schema "component" do
    field(:callback_module, :string)
    field(:data, :map, default: %{})
    belongs_to(:object, Exmud.Engine.Schema.Object, foreign_key: :object_id)

    timestamps()
  end

  def new(params) do
    %Exmud.Engine.Schema.Component{}
    |> cast(params, [:data, :callback_module, :object_id])
    |> validate_required([:callback_module, :object_id])
    |> foreign_key_constraint(:object_id)
    |> unique_constraint(:callback_module, name: :component_object_id_callback_module_index)
  end
end
