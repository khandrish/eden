defmodule Exmud.Engine.Schema.Link do
  use Exmud.Common.Schema

  schema "link" do
    field(:type, :string)
    field(:data, :binary, default: nil)
    belongs_to(:to, Exmud.Engine.Schema.Object, foreign_key: :to_id)
    belongs_to(:from, Exmud.Engine.Schema.Object, foreign_key: :from_id)
  end

  def new(link, params \\ %{}) do
    link
    |> cast(params, [:data, :from_id, :type, :to_id])
    |> validate_required([:data, :from_id, :type, :to_id])
    |> foreign_key_constraint(:to_id)
    |> foreign_key_constraint(:from_id)
  end

  def update(link, params \\ %{}) do
    link
    |> cast(params, [:type, :data])
  end
end
