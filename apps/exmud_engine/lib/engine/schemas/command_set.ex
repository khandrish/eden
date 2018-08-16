defmodule Exmud.Engine.Schema.CommandSet do
  use Exmud.Common.Schema

  schema "command_set" do
    field(:callback_module, :string)
    field(:config, :binary)
    field(:visibility, :binary)
    belongs_to(:object, Exmud.Engine.Schema.Object, foreign_key: :object_id)

    timestamps()
  end

  def new(params) do
    %Exmud.Engine.Schema.CommandSet{}
    |> cast(params, [:config, :callback_module, :object_id, :visibility])
    |> validate_required([:config, :callback_module, :object_id, :visibility])
    |> foreign_key_constraint(:object_id)
    |> unique_constraint(:callback_module, name: :command_set_callback_module_index)
  end
end
