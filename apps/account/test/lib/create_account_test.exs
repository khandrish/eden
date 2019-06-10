defmodule Exmud.Account.CreateAccountTest do
  use Exmud.Account.RepoTestCase

  alias Exmud.Account

  describe "Initial creation:" do
    test "valid data", _context do
      username = Faker.String.base64(8)
      password = Faker.String.base64(24)
      email = Faker.Nato.letter_code_word() <> "@" <> Faker.Nato.letter_code_word() <> ".com"
      nickname = Faker.Name.name()
      assert elem(Account.create(username, password, email, nickname), 0) == :ok
    end

    test "username too short", _context do
      username = Faker.String.base64(2)
      password = Faker.String.base64(24)
      email = Faker.Nato.letter_code_word() <> "@" <> Faker.Nato.letter_code_word() <> ".com"
      nickname = Faker.Name.name()
      assert elem(Account.create(username, password, email, nickname), 0) == :error
    end

    test "password too short", _context do
      username = Faker.String.base64(8)
      password = Faker.String.base64(2)
      email = Faker.Nato.letter_code_word() <> "@" <> Faker.Nato.letter_code_word() <> ".com"
      nickname = Faker.Name.name()
      assert elem(Account.create(username, password, email, nickname), 0) == :error
    end

    test "email invalid", _context do
      username = Faker.String.base64(8)
      password = Faker.String.base64(24)
      email = "x"
      nickname = Faker.Name.name()
      assert elem(Account.create(username, password, email, nickname), 0) == :error
    end

    test "nickname too long", _context do
      username = Faker.String.base64(8)
      password = Faker.String.base64(24)
      email = Faker.Nato.letter_code_word() <> "@" <> Faker.Nato.letter_code_word() <> ".com"
      nickname = Faker.String.base64(60)
      assert elem(Account.create(username, password, email, nickname), 0) == :error
    end
  end

  describe "Duplicate creation:" do
    setup [:create]

    test "cannot use duplicate username", %{account: account, password: password} = _context do
      email = Faker.Nato.letter_code_word() <> "@" <> Faker.Nato.letter_code_word() <> ".com"
      nickname = Faker.Name.name()
      assert elem(Account.create(account.username, password, email, nickname), 0) == :error
    end

    test "cannot use duplicate nickname", %{account: account, password: password} = _context do
      email = Faker.Nato.letter_code_word() <> "@" <> Faker.Nato.letter_code_word() <> ".com"
      username = Faker.String.base64(8)
      assert elem(Account.create(username, password, email, account.nickname), 0) == :error
    end

    test "cannot use duplicate email", %{account: account, password: password} = _context do
      username = Faker.String.base64(8)
      nickname = Faker.Name.name()
      assert elem(Account.create(username, password, account.email, nickname), 0) == :error
    end
  end

  defp create(_context) do
    username = Faker.String.base64(8)
    password = Faker.String.base64(24)
    email = Faker.Nato.letter_code_word() <> "@" <> Faker.Nato.letter_code_word() <> ".com"
    nickname = Faker.Name.name()
    {:ok, account} = Account.create(username, password, email, nickname)

    %{account: account, password: password}
  end
end
