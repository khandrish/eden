defmodule Exmud.Account.Schema.AccountModel do
  @moduledoc """
  Represents an Account.
  """

  import Ecto.Changeset
  use Ecto.Schema

  @account_validation_module Application.get_env(
                               :moerae,
                               :account_validation_module,
                               Exmud.Account.Validator.DefaultAccountValidator
                             )

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
  @spec create(params :: map()) :: Ecto.Changeset.t()
  def create(params \\ %{}) do
    %__MODULE__{}
    |> cast(params, [:email, :nickname, :password, :username])
    |> validate_required([:email, :nickname, :password, :username])
    |> @account_validation_module.validate_email()
    |> @account_validation_module.validate_nickname()
    |> @account_validation_module.validate_password()
    |> @account_validation_module.validate_username()
    |> hash_password()
  end

  @doc """
  Given a changeset and a map containing an email, return a modified Account changeset.
  """
  @spec update_email(account :: __MODULE__, email :: String.t()) :: Ecto.Changeset.t()
  def update_email(account, email) do
    account
    |> cast(
      %{email: email, email_verified: account.email == email and account.email_verified},
      [:email, :email_verified]
    )
    |> validate_required(:email)
    |> @account_validation_module.validate_email()
  end

  @doc """
  Given a changeset and a map containing a nickname, return a modified Account changeset.
  """
  @spec update_nickname(account :: __MODULE__, nickname :: String.t()) :: Ecto.Changeset.t()
  def update_nickname(account, nickname) do
    account
    |> cast(%{nickname: nickname}, [:nickname])
    |> validate_required(:nickname)
    |> @account_validation_module.validate_nickname()
  end

  @doc """
  Given a changeset and a map containing a password, return a modified Account changeset.

  If password is valid it will be hashed in place, meaning the Changeset returned will not contain the original raw
  password.
  """
  @spec update_password(account :: __MODULE__, password :: String.t()) :: Ecto.Changeset.t()
  def update_password(account, password) do
    account
    |> cast(%{password: password}, [:password])
    |> validate_required(:password)
    |> @account_validation_module.validate_password()
    |> hash_password()
  end

  @doc """
  Given a changeset and a map containing a username, return a modified Account changeset.
  """
  @spec update_username(account :: __MODULE__, username :: String.t()) :: Ecto.Changeset.t()
  def update_username(account, username) do
    account
    |> cast(%{username: username}, [:username])
    |> validate_required(:username)
    |> @account_validation_module.validate_username()
  end

  defp hash_password(changeset) do
    if changeset.valid? do
      put_change(changeset, :password, Argon2.hash_pwd_salt(get_change(changeset, :password)))
    else
      changeset
    end
  end
end
