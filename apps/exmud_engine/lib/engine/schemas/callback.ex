defmodule Exmud.Engine.Schema.Callback do
  use Exmud.Common.Schema

  schema "callback" do
    field :key, :string
    field :name, :string
    field :data, :binary
    belongs_to :object, Exmud.Engine.Schema.Object, foreign_key: :object_id
  end

  def new(params) do
    %Exmud.Engine.Schema.Callback{}
    |> cast(params, [:key, :name, :object_id, :data])
    |> validate_required([:key, :name, :object_id, :data])
    |> foreign_key_constraint(:object_id)
    |> unique_constraint(:key, name: :callback_object_id_key_index)
  end
end