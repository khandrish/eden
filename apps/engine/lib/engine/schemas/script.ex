defmodule Exmud.Engine.Schema.Script do
  use Exmud.Common.Schema

  schema "script" do
    field(:callback_module, :binary)
    field(:state, :binary)
    belongs_to(:object, Exmud.Engine.Schema.Object, foreign_key: :object_id)
  end

  def new(params) do
    %Exmud.Engine.Schema.Script{}
    |> cast(params, [:callback_module, :object_id, :state])
    |> validate_required([:callback_module, :object_id, :state])
    |> foreign_key_constraint(:object_id)
  end
end
