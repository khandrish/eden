defmodule Exmud.Account.AuthenticateAccountTest do
  use Exmud.Account.RepoTestCase

  alias Exmud.Account

  setup context do
    username = Faker.String.base64(8)
    password = Faker.String.base64(24)
    email = Faker.Nato.letter_code_word() <> "@" <> Faker.Nato.letter_code_word() <> ".com"
    nickname = Faker.Name.name()
    {:ok, account} = Account.create(username, password, email, nickname)

    context |> Map.put(:account, account) |> Map.put(:password, password)
  end

  test "Account can be successfully authenticated",
       %{account: account, password: password} = _context do
    {:ok, acct} = Account.authenticate(account.username, password)
    assert acct.username == account.username
  end

  test "Account cannot be successfully authenticated with wrong username",
       %{password: password} = _context do
    assert elem(Account.authenticate("foo", password), 0) == :error
  end

  test "Account cannot be successfully authenticated with wrong password",
       %{account: account} = _context do
    assert elem(Account.authenticate(account.username, "foobar"), 0) == :error
  end

  test "Account password can be successfully validated",
       %{account: account, password: password} = _context do
    assert Account.validate_password(account, password) == :ok
  end

  test "Account password cannot be successfully validated with wrong password",
       %{account: account} = _context do
    assert Account.validate_password(account, "foobar") == {:error, :no_match}
  end
end
