defmodule Exmud.Account.AuthEmail do
  @moduledoc false

  use Exmud.Schema
  import Ecto.Changeset

  @primary_key {:email, :binary, []}

  schema "auth_emails" do
    field :email_verified, :boolean, default: false
    field :hash, :binary
    belongs_to(:player, Exmud.Account.Player)

    timestamps()
  end

  def changeset(profile) do
    change(profile)
  end

  def update(profile, attrs) do
    profile
    |> cast(attrs, [:email, :hash, :email_verified])
    |> validate()
  end

  def new(attrs) when is_map(attrs) do
    %__MODULE__{}
    |> cast(attrs, [:email, :email_verified, :hash, :player_id])
    |> validate_required([:email, :hash, :player_id])
    |> validate()
  end

  @spec validate(Ecto.Changeset.t(), boolean) :: Ecto.Changeset.t()
  def validate(auth_email, unsafe \\ false) do
    auth_email =
      auth_email
      |> change()
      |> validate_format(:email, ~r/.+@.+/)
      |> validate_length(:email, min: 3, max: 254)
      |> unique_constraint(:email)

    if unsafe do
      unsafe_validate_unique(auth_email, [:email], Exmud.Repo)
    else
      auth_email
    end
  end
end
