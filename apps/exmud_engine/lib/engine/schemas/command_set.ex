defmodule Exmud.Engine.Schema.CommandSet do
  use Exmud.Common.Schema

  schema "command_set" do
    field :name, :string
    field :config, :binary
    belongs_to :object, Exmud.Engine.Schema.Object, foreign_key: :object_id
  end

  def new(params) do
    %Exmud.Engine.Schema.CommandSet{}
    |> cast(params, [:config, :name, :object_id])
    |> validate_required([:config, :name, :object_id])
    |> foreign_key_constraint(:object_id)
    |> unique_constraint(:name, name: :command_set_name_object_id_index)
  end
end