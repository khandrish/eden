defmodule Exmud.Engine.Schema.Callback do
  use Exmud.Common.Schema

  schema "callback" do
    field :key, :string
    field :callback_function, :binary
    belongs_to :object, Exmud.Engine.Schema.Object, foreign_key: :object_id
  end

  def add(callback, params \\ %{}) do
    callback
    |> cast(params, [:key, :callback_function, :object_id])
    |> validate_required([:key, :callback_function, :object_id])
    |> foreign_key_constraint(:object_id)
  end
end