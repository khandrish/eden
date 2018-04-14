defmodule Exmud.Engine.Schema.System do
  use Exmud.Common.Schema

  schema "system" do
    field :name, :string
    field :state, :binary
    belongs_to :object, Exmud.Engine.Schema.Object, foreign_key: :object_id
  end

  def new(params) do
    %Exmud.Engine.Schema.System{}
    |> cast(params, [:name, :object_id, :state])
    |> validate_required([:name, :object_id])
    |> unique_constraint(:name, [message: :key_in_use])
  end
end