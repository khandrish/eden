defmodule Exmud.Engine.Mud do
  use Ecto.Schema
  import Ecto.Changeset

  @timestamps_opts [type: :utc_datetime_usec]

  schema "muds" do
    field :name, :string
    field :status, :string, default: "stopped"
    has_many(:callbacks, Exmud.Engine.MudCallback)
    has_many(:templates, Exmud.Engine.Template)

    timestamps()
  end

  @doc false
  def changeset(mud, attrs) do
    mud
    |> cast(attrs, [:name, :status])
    |> validate_required([:name, :status])
    |> validate_length(:name, min: 2, max: 30)
    |> unique_constraint(:name)
  end

  @doc """
  Create a new Mud.

  Must provide name at a minimum.
  """
  def new(attrs) when is_map(attrs) do
    %__MODULE__{}
    |> cast(attrs, [:name, :status])
    |> validate_required([:name])
    |> validate_length(:name, min: 2, max: 30)
    |> unique_constraint(:name)
  end
end
