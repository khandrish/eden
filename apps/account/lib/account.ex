defmodule Exmud.Account do
  @moduledoc """
  General management of an Account.
  """

  alias Exmud.Account.Repo
  alias Exmud.Account.Schema.AccountModel
  alias Exmud.Account.Schema.AccountToken
  import Ecto.Query, only: [from: 2]

  @doc """
  Authenticate a username/password pair.

  Will not indicate which of the two is wrong if there is no match. Will perform a password check against a nonexisting
  password in the case that no account associated with a username is found to help against timing attacks.
  """
  @spec authenticate(username :: String.t(), password :: String.t()) ::
          {:ok, AccountModel.t()} | {:error, :no_match}
  def authenticate(username, password) do
    query =
      from(account in AccountModel,
        where: account.username == ^username
      )

    case Repo.one(query) do
      %AccountModel{} = account ->
        if Argon2.verify_pass(password, account.password) do
          {:ok, %{account | password: nil}}
        else
          {:error, :no_match}
        end

      nil ->
        Argon2.no_user_verify()
        {:error, :no_match}
    end
  end

  @doc """
  Create an Account

  In the case that an Account is successfully created, the returned record will not contain the hashed password.
  """
  @spec create(
          username :: String.t(),
          password :: String.t(),
          email :: String.t(),
          nickname :: String.t()
        ) ::
          {:ok, AccountModel.t()}
          | {:error, Ecto.Changeset.t()}
  def create(username, password, email, nickname) do
    changeset =
      AccountModel.create(%{
        username: username,
        password: password,
        email: email,
        nickname: nickname
      })

    if changeset.valid? do
      changeset = Ecto.Changeset.put_change(changeset, :password, Argon2.hash_pwd_salt(password))

      case Repo.insert(changeset) do
        {:ok, account} ->
          {:ok, %{account | password: nil}}

        error ->
          error
      end
    else
      {:error, changeset}
    end
  end

  @doc """
  Delete an account.

  Yes, it's destructive. Yes, all information about an account will be lost.
  """
  @spec delete((account_id :: integer()) | (record :: AccountModel.t())) ::
          :ok | {:error, :invalid_account}
  def delete(account_id) when is_integer(account_id), do: delete(%AccountModel{id: account_id})

  def delete(%AccountModel{} = account_record) do
    case Repo.delete(account_record) do
      {:ok, _} ->
        :ok

      {:error, _} ->
        {:error, :invalid_account}
    end
  end

  @doc """
  Retrieve an account by id.
  """
  @spec get(account_id :: integer()) ::
          {:ok, account :: AccountModel.t()} | {:error, :no_account}
  def get(account_id) when is_integer(account_id) do
    case Repo.get(AccountModel, account_id) do
      nil ->
        {:error, :no_account}

      account ->
        {:ok, account}
    end
  end

  @doc """
  Query accounts by providing an Ecto dynamic query expression to be used as the root of a where clause.

  Returns a list of Accounts that match the criteria.
  """
  @spec query(ecto_dynamic_where_clause :: term()) :: [AccountModel.t()]
  def query(where_fragment) do
    query =
      from(account in AccountModel,
        where: ^where_fragment,
        select: [:id, :email, :email_verified, :nickname, :username]
      )

    Repo.all(query)
  end

  @doc """
  Persist an updated Account changeset.

  For this function to do anything the changeset must have been updated using the update_* functions in the
  Exmud.Account.Schema.AccountModel module, or directly using `Ecto.cast()`.
  """
  def update(changeset) do
    case Repo.update(changeset) do
      {:ok, account} ->
        {:ok, %{account | password: nil}}

      error ->
        error
    end
  end

  @doc """
  Given an Account schema or an Account id, and a password, validates that the password matches.
  """
  @spec validate_password(account_id :: integer(), password :: String.t()) ::
          :ok | {:error, :no_match} | {:error, :invalid_account}
  def validate_password(%AccountModel{} = account, password),
    do: validate_password(account.id, password)

  def validate_password(account_id, password) do
    query =
      from(account in "account",
        where: account.id == ^account_id,
        select: account.password
      )

    case Repo.one(query) do
      nil ->
        {:error, :invalid_account}

      pw ->
        if Argon2.verify_pass(password, pw) do
          :ok
        else
          {:error, :no_match}
        end
    end
  end
end
