defmodule Exmud.Engine.Schema.CallbackSet do
  use Exmud.Common.Schema

  schema "callback_set" do
    field(:name, :string)
    field(:config, :binary)
    belongs_to(:object, Exmud.Engine.Schema.Object, foreign_key: :object_id)

    timestamps()
  end

  def new(params) do
    %Exmud.Engine.Schema.CallbackSet{}
    |> cast(params, [:name, :object_id])
    |> validate_required([:name, :object_id])
    |> foreign_key_constraint(:object_id)
    |> unique_constraint(:name, name: :callback_set_name_object_id_index)
  end
end
