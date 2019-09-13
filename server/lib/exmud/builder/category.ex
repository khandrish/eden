defmodule Exmud.Builder.Category do
  use Ecto.Schema
  import Ecto.Changeset

  @timestamps_opts [type: :utc_datetime_usec]
  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  @derive {Phoenix.Param, key: :slug}
  schema "categories" do
    field :name, :string
    field :description, :string
    belongs_to :category, Exmud.Builder.Category
    belongs_to :mud, Exmud.Engine.Mud

    field :slug, Exmud.DataType.NameSlug.Type

    timestamps()
  end

  @doc false
  def changeset(category, attrs) do
    category
    |> cast(attrs, [:description, :name])
    |> validate_required([:name])
    |> unique_constraint(:name)
    |> Exmud.DataType.NameSlug.maybe_generate_slug()
    |> Exmud.DataType.NameSlug.unique_constraint()
  end
end
