defmodule Exmud.Engine.Schema.Lock do
  use Exmud.Common.Schema

  schema "lock" do
    field :access_type, :string
    field :name, :string
    field :config, :binary
    belongs_to :object, Exmud.Engine.Schema.Object, foreign_key: :object_id
  end

  def new(params) do
    %Exmud.Engine.Schema.Lock{}
    |> cast(params, [:access_type, :object_id, :name, :config])
    |> validate_required([:access_type, :object_id, :name])
    |> foreign_key_constraint(:object_id)
  end
end