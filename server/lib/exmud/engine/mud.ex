defmodule Exmud.Engine.Mud do
  use Exmud.Schema
  import Ecto.Changeset

  @derive {Phoenix.Param, key: :slug}
  schema "muds" do
    field :name, :string
    field :description, :string
    field :slug, Exmud.DataType.NameSlug.Type

    belongs_to(:player, Exmud.Account.Player)

    timestamps()
  end

  @doc """
  Create a new Mud.

  Must provide name and description at a minimum.
  """
  def new(attrs) when is_map(attrs) do
    %__MODULE__{}
    |> cast(attrs, [:description, :name, :player_id])
    |> validate()
  end

  @doc """
  Update an existing Mud.

  May provide name or description.
  """
  def update(mud = %__MODULE__{}, attrs) when is_map(attrs) do
    mud
    |> cast(attrs, [:description, :name, :player_id])
    |> validate()
  end

  defp validate(mud) do
    mud
    |> validate_required([:name])
    |> validate_length(:name, min: 2, max: 60)
    |> unique_constraint(:name)
    |> Exmud.DataType.NameSlug.maybe_generate_slug()
    |> Exmud.DataType.NameSlug.unique_constraint()
  end
end
