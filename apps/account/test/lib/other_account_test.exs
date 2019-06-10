defmodule Exmud.Account.OtherAccountTest do
  use Exmud.Account.RepoTestCase

  alias Exmud.Account
  alias Exmud.Account.Schema.AccountModel
  import Ecto.Query, only: [dynamic: 2]

  setup context do
    username = Faker.String.base64(8)
    password = Faker.String.base64(24)
    email = Faker.Nato.letter_code_word() <> "@" <> Faker.Nato.letter_code_word() <> ".com"
    nickname = Faker.Name.name()
    {:ok, account} = Account.create(username, password, email, nickname)

    context |> Map.put(:account, account) |> Map.put(:password, password)
  end

  test "An account can be deleted", %{account: account} = _context do
    assert Account.delete(account.id) == :ok
  end

  test "An account can be retrieved by id", %{account: account} = _context do
    assert elem(Account.get(account.id), 0) == :ok
  end

  test "An account can be retrieved by query", %{account: account} = _context do
    where_clause = dynamic([acc], acc.username == ^account.username)
    [acc] = Account.query(where_clause)

    assert acc.username == account.username
  end

  test "An account can be updated", %{account: account} = _context do
    new_username = Faker.String.base64(10)

    {:ok, updated_account} =
      AccountModel.update_username(account, new_username) |> Account.update()

    assert updated_account.username == new_username
  end

  test "An account cannot be updated with invalid info", %{account: account} = _context do
    new_username = Faker.String.base64(2)

    result = AccountModel.update_username(account, new_username) |> Account.update()

    assert elem(result, 0) == :error
  end
end
