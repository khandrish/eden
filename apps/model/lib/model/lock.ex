defmodule Model.Lock do
  import Ecto.Changeset

  use Ecto.Schema

  schema "lock" do
    field(:access_type, :string)
    field(:callback_module, Model.Type.CallbackModule)
    field(:config, :map, default: %{})
    belongs_to(:object, Model.Object, foreign_key: :object_id)

    timestamps()
  end

  def new(params) when is_map(params) do
    %__MODULE__{}
    |> cast(params, [:access_type, :object_id, :callback_module, :config])
    |> validate_required([:access_type, :object_id, :callback_module])
    |> foreign_key_constraint(:object_id)
    |> unique_constraint(:access_type, name: :lock_object_id_access_type_index)
  end

  def update(lock, params) when is_map(params) do
    lock
    |> cast(params, [:config])
    |> Model.Validations.validate_map(:config)
  end
end
