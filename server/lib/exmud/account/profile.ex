defmodule Exmud.Account.Profile do
  @moduledoc """
  Provides the tools necessary to manage a Player Profile.
  """
  use Ecto.Schema
  import Ecto.Changeset
  @timestamps_opts [type: :utc_datetime_usec]

  @derive {Phoenix.Param, key: :slug}
  schema "profiles" do
    field :email, :string
    field :email_verified, :boolean, default: false
    field :nickname, :string
    field :tos_accepted, :boolean, default: false
    belongs_to(:player, Exmud.Account.Player, foreign_key: :player_id)

    field :slug, Exmud.DataType.NicknameSlug.Type

    timestamps()
  end

  @doc """
  Change a Profile struct into a changeset.
  """
  def changeset(profile) do
    change(profile)
  end

  @doc """
  Update a Profile struct/changeset and validate the changes.
  """
  def update(profile, attrs) do
    profile
    |> cast(attrs, [:nickname, :email, :email_verified, :tos_accepted])
    |> validate()
  end

  @doc """
  Create a new Profile.

  Must provide email, nickname, and player_id at a minimum.
  """
  def new(attrs) when is_map(attrs) do
    %__MODULE__{}
    |> cast(attrs, [:nickname, :email, :email_verified, :tos_accepted, :player_id])
    |> validate()
  end

  @spec validate(Ecto.Changeset.t()) :: Ecto.Changeset.t()
  def validate(profile) do
    nickname_max = Application.get_env(:exmud, :nickname_max_length, 30)
    nickname_min = Application.get_env(:exmud, :nickname_min_length, 2)
    nickname_format = Application.get_env(:exmud, :nickname_format, ~r/[a-zA-Z0-9 ]/)

    profile
    |> validate_format(:email, ~r/.+@.+/)
    |> validate_length(:email, min: 3, max: 254)
    |> validate_format(:nickname, nickname_format)
    |> validate_length(:nickname, min: nickname_min, max: nickname_max)
    |> unique_constraint(:nickname)
    |> unique_constraint(:email)
    |> unsafe_validate_unique([:nickname], Exmud.Repo)
    |> unsafe_validate_unique([:email], Exmud.Repo)
    |> Exmud.DataType.NicknameSlug.maybe_generate_slug()
    |> Exmud.DataType.NicknameSlug.unique_constraint()
  end
end
