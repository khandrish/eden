defmodule Exmud.Engine.Schema.Lock do
  use Exmud.Common.Schema

  schema "lock" do
    field(:access_type, :string)
    field(:callback_module, :string)
    field(:config, :map, default: %{})
    belongs_to(:object, Exmud.Engine.Schema.Object, foreign_key: :object_id)

    timestamps()
  end

  def new(params) do
    %Exmud.Engine.Schema.Lock{}
    |> cast(params, [:access_type, :object_id, :callback_module, :config])
    |> validate_required([:access_type, :object_id, :callback_module])
    |> foreign_key_constraint(:object_id)
    |> unique_constraint(:access_type, name: :lock_object_id_access_type_index)
  end
end
