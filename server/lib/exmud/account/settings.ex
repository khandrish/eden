defmodule Exmud.Account.Settings do
  @moduledoc false

  use Exmud.Schema

  import Ecto.Changeset

  @primary_key {:player_id, :binary_id, autogenerate: false}
  schema "player_settings" do
    field :developer_feature_on, :boolean, default: false

    belongs_to(:player, Exmud.Account.Player, type: :binary_id, foreign_key: :player_id, primary_key: true, define_field: false)

    timestamps()
  end

  def changeset(profile) do
    change(profile)
  end

  def update(profile, attrs) do
    profile
    |> cast(attrs, [:developer_feature_on])
    |> validate()
  end

  def new(attrs) when is_map(attrs) do
    %__MODULE__{}
    |> cast(attrs, [:developer_feature_on, :player_id])
    |> validate()
  end

  @spec validate(Ecto.Changeset.t(), boolean) :: Ecto.Changeset.t()
  def validate(settings, unsafe \\ false) do
    settings
  end
end
