defmodule Exmud.Account.Profile do
  @moduledoc false

  use Exmud.Schema

  import Ecto.Changeset

  @primary_key {:player_id, :binary_id, autogenerate: false}
  @derive {Phoenix.Param, key: :slug}
  schema "profiles" do
    field :email, :string
    field :email_verified, :boolean, default: false
    field :nickname, :string
    field :slug, Exmud.DataType.NicknameSlug.Type

    belongs_to(:player, Exmud.Account.Player,
      type: :binary_id,
      foreign_key: :player_id,
      primary_key: true,
      define_field: false
    )

    timestamps()
  end

  def changeset(profile) do
    change(profile)
  end

  def update(profile, attrs) do
    profile
    |> cast(attrs, [:nickname, :email, :email_verified])
    |> validate()
  end

  def new(attrs) when is_map(attrs) do
    %__MODULE__{}
    |> cast(attrs, [:nickname, :email, :email_verified, :player_id])
    |> validate()
  end

  @spec validate(Ecto.Changeset.t(), boolean) :: Ecto.Changeset.t()
  def validate(profile, unsafe \\ false) do
    email_format = Application.get_env(:exmud, :email_format)
    email_max_length = Application.get_env(:exmud, :email_max_length)
    email_min_length = Application.get_env(:exmud, :email_min_length)
    nickname_format = Application.get_env(:exmud, :nickname_format)
    nickname_max_length = Application.get_env(:exmud, :nickname_max_length)
    nickname_min_length = Application.get_env(:exmud, :nickname_min_length)

    profile =
      profile
      |> change()
      |> validate_required([:email_verified, :player_id])
      |> foreign_key_constraint(:player_id)
      |> unique_constraint(:email)
      |> validate_format(:email, email_format)
      |> validate_length(:email, min: email_min_length, max: email_max_length)
      |> unique_constraint(:nickname)
      |> validate_format(:nickname, nickname_format)
      |> validate_length(:nickname, min: nickname_min_length, max: nickname_max_length)
      |> Exmud.DataType.NicknameSlug.maybe_generate_slug()
      |> Exmud.DataType.NicknameSlug.unique_constraint()

    if unsafe do
      profile
      |> unsafe_validate_unique([:email], Exmud.Repo)
      |> unsafe_validate_unique([:nickname], Exmud.Repo)
      |> unsafe_validate_unique([:slug], Exmud.Repo)
    else
      profile
    end
  end
end
