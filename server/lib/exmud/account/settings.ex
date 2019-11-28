defmodule Exmud.Account.Settings do
  @moduledoc false

  use Exmud.Schema

  import Ecto.Changeset

  @primary_key {:player_id, :binary_id, autogenerate: false}
  schema "player_settings" do
    field :developer_feature_on, :boolean, default: false

    belongs_to(:player, Exmud.Account.Player,
      type: :binary_id,
      foreign_key: :player_id,
      primary_key: true,
      define_field: false
    )

    timestamps()
  end

  @spec changeset(__MODULE__.t() | Ecto.Changeset.t()) :: Ecto.Changeset.t()
  def changeset(profile) do
    change(profile)
  end

  @spec update(__MODULE__.t() | Ecto.Changeset.t(), map) :: Ecto.Changeset.t()
  def update(profile, attrs) do
    profile
    |> cast(attrs, [:developer_feature_on])
    |> validate()
  end

  @spec new(map) :: Ecto.Changeset.t()
  def new(attrs) when is_map(attrs) do
    %__MODULE__{}
    |> cast(attrs, [:developer_feature_on, :player_id])
    |> validate()
  end

  @spec validate(Ecto.Changeset.t()) :: Ecto.Changeset.t()
  def validate(settings) do
    settings
    |> validate_inclusion(:developer_feature_on, [true, false])
  end
end
