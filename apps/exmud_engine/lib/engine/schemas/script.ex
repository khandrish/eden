defmodule Exmud.Engine.Schema.Script do
  use Exmud.Common.Schema

  schema "script" do
    field :callback_module, :binary
    field :key, :string
    field :options, :binary
    field :state, :binary
    belongs_to :object, Exmud.Engine.Schema.Object, foreign_key: :object_id
  end

  def cast(system), do: cast(system, %{}, [])

  def changeset(script, params \\ %{}) do
    script
    |> cast(params, [:key, :object_id, :options, :state])
    |> validate_required([:key, :object_id, :options, :state])
    |> foreign_key_constraint(:object_id)
  end
end