defmodule Exmud.Builder.Prototype do
  use Ecto.Schema
  import Ecto.Changeset

  @derive {Phoenix.Param, key: :slug}
  schema "prototypes" do
    field :name, :string
    field :description, :string
    belongs_to :category, Exmud.Builder.Category
    belongs_to :mud, Exmud.Engine.Mud

    field :slug, Exmud.DataType.NameSlug.Type

    timestamps()
  end

  @doc false
  def changeset(prototype, attrs) do
    prototype
    |> cast(attrs, [:description, :name])
    |> validate_required([:name])
    |> unique_constraint(:name)
    |> Exmud.DataType.NameSlug.maybe_generate_slug()
    |> Exmud.DataType.NameSlug.unique_constraint()
  end
end
