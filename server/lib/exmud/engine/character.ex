defmodule Exmud.Engine.Character do
  use Exmud.Schema
  import Ecto.Changeset

  schema "characters" do
    field :name, :string
    field :player_id, :binary_id
    field :mud_id, :binary_id
    field :slug, Exmud.DataType.NameSlug.Type

    timestamps()
  end

  @doc false
  def new(attrs) when is_map(attrs) do
    %__MODULE__{}
    |> cast(attrs, [:name])
    |> validate_required([:name])
    |> Exmud.DataType.NameSlug.maybe_generate_slug()
    |> Exmud.DataType.NameSlug.unique_constraint()
  end

  @doc false
  def update(character = %__MODULE__{}, attrs) when is_map(attrs) do
    character
    |> cast(attrs, [:name])
    |> validate_required([:name])
    |> Exmud.DataType.NameSlug.maybe_generate_slug()
    |> Exmud.DataType.NameSlug.unique_constraint()
  end
end
