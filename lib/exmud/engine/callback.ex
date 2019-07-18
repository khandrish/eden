defmodule Exmud.Engine.Callback do
  use Ecto.Schema
  import Ecto.Changeset

  @timestamps_opts [type: :utc_datetime_usec]

  schema "callbacks" do
    field :default_args, :map
    field :module, Exmud.Type.CallbackModule
    field :type, :string
    field :docs, :string, virtual: true

    timestamps()
  end

  @doc false
  def changeset(callback, attrs) do
    callback
    |> cast(attrs, [:module, :type, :default_args])
    |> validate_required([:module, :type, :default_args])
    |> unique_constraint(:module)
  end
end
