defmodule Exmud.Engine.Callbacks do
  use Ecto.Schema
  import Ecto.Changeset

  schema "callbacks" do
    field :default_args, :binary
    field :module, :string
    field :type, :string

    timestamps()
  end

  @doc false
  def changeset(callbacks, attrs) do
    callbacks
    |> cast(attrs, [:module, :type, :default_args])
    |> validate_required([:module, :type, :default_args])
    |> unique_constraint(:module)
  end
end
