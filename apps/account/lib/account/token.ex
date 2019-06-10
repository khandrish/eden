defmodule Exmud.Account.Token do
  @moduledoc """
  Facilitates working with account tokens.
  """

  alias Exmud.Account.Repo
  alias Exmud.Account.Schema.AccountModel
  alias Exmud.Account.Schema.AccountToken
  import Ecto.Query, only: [from: 2]

  @doc """
  Delete a token of a specified type.
  """
  @spec delete(token :: String.t(), type :: String.t()) :: :ok | {:error, :invalid_token}
  def delete(token, type) do
    query =
      from(
        tok in AccountToken,
        where: tok.token == ^token and tok.type == ^type
      )

    case Repo.delete_all(query) do
      {1, _} ->
        :ok

      _ ->
        {:error, :invalid_token}
    end
  end

  @doc """
  Generate a token.

  The token can be used for any purpose which requires being able to link to an account not via username/password combo.
  """
  @spec generate(
          (account :: AccountModel.t()) | (account_id :: integer()),
          type :: String.t(),
          expiry :: DateTime.t() | nil
        ) :: {:ok, token :: String.t()} | {:error, [{atom(), {String.t(), Keyword.t()}}]}
  def generate(account_id, type, expiry \\ nil)

  def generate(%AccountModel{} = account, type, expiry),
    do: generate(account.id, type, expiry)

  def generate(account_id, type, expiry)
      when is_integer(account_id) and is_binary(type) do
    expiry =
      if is_nil(expiry) do
        nil
      else
        DateTime.truncate(expiry, :second)
      end

    AccountToken.new(%{
      account_id: account_id,
      token: UUID.uuid4(),
      type: type,
      expiry: expiry
    })
    |> Repo.insert()
    |> case do
      {:ok, record} ->
        {:ok, record}

      {:error, %{errors: errors} = _changeset} ->
        {:error, errors}
    end
  end

  @doc """
  Get a token struct from the database using a token string.
  """
  @spec get(token :: String.t(), type :: String.t()) ::
          {:ok, AccountToken.t()} | {:error, :invalid_token}
  def get(token, type) do
    query =
      from(
        tok in AccountToken,
        where:
          tok.token == ^token and tok.type == ^type and
            (is_nil(tok.expiry) or tok.expiry > ^Timex.now())
      )

    case Repo.one(query) do
      nil ->
        {:error, :invalid_token}

      token ->
        {:ok, token}
    end
  end

  @doc """
  Get an account given a token.
  """
  @spec get_account(token :: String.t(), type :: String.t()) ::
          {:ok, AccountModel.t()} | {:error, :invalid_token}
  def get_account(token, type) do
    query =
      from(
        account in AccountModel,
        join: tok in AccountToken,
        on: account.id == tok.account_id,
        where:
          tok.token == ^token and tok.type == ^type and
            (is_nil(tok.expiry) or tok.expiry > ^Timex.now()),
        select: [:id, :username, :nickname, :email, :email_verified]
      )

    case Repo.one(query) do
      nil ->
        {:error, :invalid_token}

      account ->
        {:ok, account}
    end
  end

  @doc """
  Save a supplied token.

  The token can be used for any purpose which requires being able to link to an account not via username/password combo.
  """
  @spec save(
          (account :: AccountModel.t()) | (account_id :: integer()),
          token :: String.t(),
          type :: String.t(),
          expiry :: DateTime.t() | nil
        ) ::
          {:ok, AccountToken.t()} | {:error, [{atom(), {String.t(), Keyword.t()}}]}
  def save(account_id, token, type, expiry \\ nil)

  def save(%AccountModel{} = account, token, type, expiry),
    do: save(account.id, token, type, expiry)

  def save(account_id, token, type, expiry) when is_integer(account_id) do
    expiry =
      if is_nil(expiry) do
        nil
      else
        DateTime.truncate(expiry, :second)
      end

    AccountToken.new(%{
      account_id: account_id,
      token: token,
      type: type,
      expiry: expiry
    })
    |> Repo.insert()
    |> case do
      {:ok, record} ->
        {:ok, record}

      {:error, %{errors: errors} = _changeset} ->
        {:error, errors}
    end
  end

  @doc """
  Check to see if a token is valid.

  Makes no distinction between an existing but not yet deleted token and a token that isn't in the database at all.
  """
  @spec valid?(token :: String.t(), type :: String.t()) :: boolean()
  def valid?(token, type) do
    query =
      from(
        tok in AccountToken,
        where:
          tok.token == ^token and
            tok.type == ^type and
            (is_nil(tok.expiry) or tok.expiry > ^Timex.now()),
        select: tok.id
      )

    Repo.one(query) != nil
  end
end
