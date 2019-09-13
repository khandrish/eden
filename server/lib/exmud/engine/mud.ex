defmodule Exmud.Engine.Mud do
  use Ecto.Schema
  import Ecto.Changeset

  @timestamps_opts [type: :utc_datetime_usec]
  @primary_key {:id, :binary_id, autogenerate: true}

  @derive {Phoenix.Param, key: :slug}
  schema "muds" do
    field :name, :string
    field :description, :string
    field :status, :string, default: "stopped"
    has_many :mud_callbacks, Exmud.Engine.MudCallback
    has_many :callbacks, through: [:mud_callbacks, :callback]
    has_many :categories, Exmud.Builder.Category
    has_many :prototypes, Exmud.Builder.Prototype
    has_many :templates, Exmud.Builder.Template

    field :slug, Exmud.DataType.NameSlug.Type

    timestamps()
  end

  @doc false
  def changeset(mud, attrs) do
    mud
    |> cast(attrs, [:description, :name, :status])
    |> validate_required([:name, :status])
    |> validate_length(:name, min: 2, max: 30)
    |> unique_constraint(:name)
    |> Exmud.DataType.NameSlug.maybe_generate_slug()
    |> Exmud.DataType.NameSlug.unique_constraint()
  end

  @doc """
  Create a new Engine.

  Must provide name at a minimum.
  """
  def new(attrs) when is_map(attrs) do
    %__MODULE__{}
    |> cast(attrs, [:description, :name, :status])
    |> validate_required([:name])
    |> validate_length(:name, min: 2, max: 30)
    |> unique_constraint(:name)
  end
end
