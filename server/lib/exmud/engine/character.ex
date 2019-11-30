defmodule Exmud.Engine.Character do
  use Exmud.Schema
  import Ecto.Changeset

  schema "characters" do
    field :name, :string
    field :slug, Exmud.DataType.NameSlug.Type

    belongs_to(:mud, Exmud.Engine.Mud)
    belongs_to(:player, Exmud.Account.Player)

    timestamps()
  end

  @doc false
  def new(attrs) when is_map(attrs) do
    %__MODULE__{}
    |> cast(attrs, [:player_id, :mud_id, :name])
    |> validate_required([:player_id, :mud_id, :name])
    |> Exmud.DataType.NameSlug.maybe_generate_slug()
    |> Exmud.DataType.NameSlug.unique_constraint()
    |> unique_constraint(:name, name: "characters_name_mud_id_index")
  end

  @doc false
  def update(character = %__MODULE__{}, attrs) when is_map(attrs) do
    character
    |> cast(attrs, [:player_id, :mud_id, :name])
    |> validate_required([:name])
    |> Exmud.DataType.NameSlug.maybe_generate_slug()
    |> Exmud.DataType.NameSlug.unique_constraint()
    |> unique_constraint(:name, name: "characters_name_mud_id_index")
  end
end
