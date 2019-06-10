defmodule Exmud.Account.EmailTest do
  use Exmud.Account.RepoTestCase

  alias Exmud.Account
  alias Exmud.Account.Email

  setup context do
    username = Faker.String.base64(8)
    password = Faker.String.base64(24)
    email = Faker.Nato.letter_code_word() <> "@" <> Faker.Nato.letter_code_word() <> ".com"
    nickname = Faker.Name.name()
    {:ok, account} = Account.create(username, password, email, nickname)

    context |> Map.put(:account, account)
  end

  test "An account can be looked up by email", %{account: account} = _context do
    assert elem(Email.lookup_account(account.email), 1) == account
  end

  test "An email address can be updated", %{account: account} = _context do
    new_email = Faker.Nato.letter_code_word() <> "@" <> Faker.Nato.letter_code_word() <> ".com"

    {:ok, updated_account} = Email.update(account, new_email)

    assert updated_account.email == new_email
  end

  test "An email address must have an @ symbol to be updated", %{account: account} = _context do
    new_email = Faker.Nato.letter_code_word() <> Faker.Nato.letter_code_word() <> ".com"

    assert elem(Email.update(account, new_email), 0) == :error
  end

  test "An account_id can be used to check if an account has a verified email",
       %{account: account} = _context do
    assert elem(Email.verified?(account.id), 0) == :ok
  end
end
