defmodule Exmud.Account.Schema.AccountModelTest do
  use ExUnit.Case, async: true

  alias Exmud.Account.Schema.AccountModel

  setup context do
    username = Faker.String.base64(8)
    password = Faker.String.base64(24)
    email = Faker.Nato.letter_code_word() <> "@" <> Faker.Nato.letter_code_word() <> ".com"
    nickname = Faker.Name.name()

    account = %AccountModel{
      username: username,
      password: password,
      email: email,
      nickname: nickname
    }

    context |> Map.put(:account, account)
  end

  test "An AccountModel struct can be modified with a new nickname",
       %{account: account} = _context do
    new_nickname = Faker.Name.name()
    changeset = AccountModel.update_nickname(account, new_nickname)
    assert changeset.valid?()
  end

  test "An AccountModel struct can be modified with a new password",
       %{account: account} = _context do
    new_password = Faker.String.base64(24)
    changeset = AccountModel.update_password(account, new_password)
    assert changeset.valid?()
  end
end
