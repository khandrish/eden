defmodule Exmud.Builder.Callback do
  use Ecto.Schema
  import Ecto.Changeset

  @timestamps_opts [type: :utc_datetime_usec]

  schema "callbacks" do
    field :config, :map
    field :module, Exmud.DataType.CallbackModule
    field :type, :string
    field :docs, :string, virtual: true
    field :config_schema, :map, virtual: true

    timestamps()
  end

  @doc false
  def changeset(callback, attrs) do
    callback
    |> cast(attrs, [:module, :type, :config])
    |> validate_required([:module, :type, :config])
    |> unique_constraint(:module)
    |> Exmud.Util.validate_json(:config)
  end
end
