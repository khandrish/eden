defmodule Model.Account do
  import Ecto.Changeset

  use Ecto.Schema

  @schema_prefix "account"
  schema "account" do
    field(:email, :string)
    field(:email_verified, :boolean, default: false)
    field(:nickname, :string)
    field(:password, :string)
    field(:username, :string)
  end

  @doc """
  Given a map of parameters, return an Account changeset.

  If changeset is valid after all non-database validations have been run, the password will be hashed in place meaning
  the Changeset returned will not contain the original raw password.
  """
  @spec new(params :: map()) :: Ecto.Changeset.t()
  def new(params) when is_map(params) do
    %__MODULE__{}
    |> cast(params, [:email, :nickname, :password, :username])
    |> validate_required([:email, :nickname, :password, :username])
    |> validate_email()
    |> validate_nickname()
    |> validate_password()
    |> validate_username()
    |> hash_password()
  end

  def update(account, params) when is_map(account) and is_map(params) do
    account
    |> cast(params, [:email, :email_verified, :nickname, :password, :username])
    |> validate_email()
    |> validate_nickname()
    |> validate_password()
    |> validate_username()
    |> hash_password()
  end

  @spec validate_email(Ecto.Changeset.t()) :: Ecto.Changeset.t()
  defp validate_email(changeset) do
    changeset
    |> validate_length(:email, min: 3, max: 254)
    |> unique_constraint(:email)
    |> validate_format(:email, ~r/@/)
  end

  @spec validate_nickname(Ecto.Changeset.t()) :: Ecto.Changeset.t()
  defp validate_nickname(changeset) do
    changeset
    |> validate_length(:nickname, min: 2, max: 30)
    |> unique_constraint(:nickname)
  end

  @spec validate_password(Ecto.Changeset.t()) :: Ecto.Changeset.t()
  defp validate_password(changeset) do
    changeset
    |> validate_length(:password, min: 20, max: 1024)
  end

  @spec validate_username(Ecto.Changeset.t()) :: Ecto.Changeset.t()
  defp validate_username(changeset) do
    changeset
    |> validate_length(:username, min: 6, max: 30)
    |> unique_constraint(:username)
  end

  defp hash_password(changeset) do
    if changeset.valid? and Ecto.Changeset.get_change(changeset, :password, false) do
      put_change(changeset, :password, Argon2.hash_pwd_salt(get_change(changeset, :password)))
    else
      changeset
    end
  end
end
