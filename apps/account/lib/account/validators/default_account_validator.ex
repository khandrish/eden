defmodule Exmud.Account.Validator.DefaultAccountValidator do
  @moduledoc """
  Performs validation on an Account schema.

  Uses the following configuration keys, with corresponding defaults:
    :email_format, ~r/@/
    :nickname_length_max, 30
    :nickname_length_min, 2
    :password_length_max, 1024
    :password_length_min, 12
    :username_length_max, 30
    :username_length_min, 6
  """

  import Ecto.Changeset

  @password_length_max Application.get_env(:exmud_account, :password_length_max, 1024)
  @password_length_min Application.get_env(:exmud_account, :password_length_min, 12)
  @username_length_max Application.get_env(:exmud_account, :username_length_max, 30)
  @username_length_min Application.get_env(:exmud_account, :username_length_min, 6)
  @nickname_length_max Application.get_env(:exmud_account, :nickname_length_max, 30)
  @nickname_length_min Application.get_env(:exmud_account, :nickname_length_min, 2)
  @email_format Application.get_env(:exmud_account, :email_format, ~r/@/)

  @behaviour Exmud.Account.AccountValidator

  @impl true
  @spec validate_email(Ecto.Changeset.t()) :: Ecto.Changeset.t()
  def validate_email(changeset) do
    changeset
    |> validate_length(:email, min: 3, max: 254)
    |> unique_constraint(:email)
    |> validate_format(:email, @email_format)
  end

  @impl true
  @spec validate_nickname(Ecto.Changeset.t()) :: Ecto.Changeset.t()
  def validate_nickname(changeset) do
    changeset
    |> validate_length(:nickname, min: @nickname_length_min, max: @nickname_length_max)
    |> unique_constraint(:nickname)
  end

  @impl true
  @spec validate_password(Ecto.Changeset.t()) :: Ecto.Changeset.t()
  def validate_password(changeset) do
    changeset
    |> validate_length(:password, min: @password_length_min, max: @password_length_max)
  end

  @impl true
  @spec validate_username(Ecto.Changeset.t()) :: Ecto.Changeset.t()
  def validate_username(changeset) do
    changeset
    |> validate_length(:username, min: @username_length_min, max: @username_length_max)
    |> unique_constraint(:username)
  end
end
