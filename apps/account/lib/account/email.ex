defmodule Exmud.Account.Email do
  @moduledoc """
  This module contains all of the methods for working with email and an account.
  """

  alias Exmud.Account
  alias Exmud.Account.Repo
  alias Exmud.Account.Schema.AccountModel
  import Ecto.Query, only: [dynamic: 2, from: 2]

  @doc """
  Lookup an account via its email address.
  """
  @spec lookup_account(email :: String.t()) ::
          {:ok, AccountModel.t()} | {:error, :email_invalid}
  def lookup_account(email) do
    where_fragment = dynamic([account], account.email == ^email)

    case Account.query(where_fragment) do
      [] ->
        {:error, :email_invalid}

      [account] ->
        {:ok, account}
    end
  end

  @doc """
  Update the email address for an account.
  """
  @spec update(account :: AccountModel.t(), email :: String.t()) ::
          {:ok, AccountModel.t()} | {:error, :email_invalid | :duplicate_email}
  def update(account, email) do
    account
    |> AccountModel.update_email(email)
    |> Account.update()
    |> case do
      {:error, changeset} ->
        {:error, List.first(Exmud.Account.Util.normalize_changeset_errors(changeset))}

      result ->
        result
    end
  end

  @doc """
  Check whether or not an email address associated with an account has been validated.

  Returns an error if no account is found with the given id.
  """
  @spec verified?(account_id :: integer()) :: {:ok, boolean()} | {:error, :invalid_account}
  def verified?(account_id) when is_integer(account_id) do
    query =
      from(
        account in AccountModel,
        where: account.id == ^account_id,
        select: account.email_verified
      )

    case Repo.one(query) do
      nil ->
        {:error, :invalid_account}

      validated ->
        {:ok, validated}
    end
  end
end
