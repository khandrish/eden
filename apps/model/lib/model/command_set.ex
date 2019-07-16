defmodule Model.CommandSet do
  import Ecto.Changeset

  use Ecto.Schema

  schema "command_set" do
    field(:callback_module, Model.Type.CallbackModule)
    field(:config, :map, default: %{})
    field(:visibility, :string)
    belongs_to(:object, Model.Object, foreign_key: :object_id)

    timestamps()
  end

  def new(params) when is_map(params) do
    %__MODULE__{}
    |> cast(params, [:config, :callback_module, :object_id, :visibility])
    |> validate_required([:config, :callback_module, :object_id, :visibility])
    |> foreign_key_constraint(:object_id)
    |> unique_constraint(:callback_module, name: :command_set_callback_module_index)
  end

  def update(command_set, params) when is_map(params) do
    command_set
    |> cast(params, [:config, :visibility])
    |> Model.Validations.validate_map(:config)
  end
end
