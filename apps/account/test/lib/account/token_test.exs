defmodule Exmud.Account.TokenTest do
  use Exmud.Account.RepoTestCase

  alias Exmud.Account
  alias Exmud.Account.Token

  describe "Initial creation:" do
    setup [:create_account]

    test "generate token", %{account: account} = _context do
      type = Faker.Nato.letter_code_word()
      assert elem(Token.generate(account, type), 0) == :ok
    end

    test "generate token with expiry", %{account: account} = _context do
      type = Faker.Nato.letter_code_word()
      assert elem(Token.generate(account, type, DateTime.utc_now()), 0) == :ok
    end

    test "save custom token", %{account: account} = _context do
      token = Faker.String.base64(24)
      type = Faker.Nato.letter_code_word()
      assert elem(Token.save(account, token, type), 0) == :ok
    end

    test "save custom token with expiry", %{account: account} = _context do
      token = Faker.String.base64(24)
      type = Faker.Nato.letter_code_word()
      assert elem(Token.save(account, token, type, DateTime.utc_now()), 0) == :ok
    end
  end

  describe "Manipulation of created tokens:" do
    setup [:create_account, :create_token]

    test "delete data", %{token: token} = _context do
      assert Token.delete(token.token, token.type) == :ok
    end

    test "get token", %{token: token} = _context do
      {:ok, tok} = Token.get(token.token, token.type)
      assert tok.id == token.id
    end

    test "get account", %{account: account, token: token} = _context do
      {:ok, acc} = Token.get_account(token.token, token.type)
      assert acc.id == account.id
    end

    test "valid?", %{token: token} = _context do
      assert Token.valid?(token.token, token.type)
    end
  end

  defp create_account(context) do
    username = Faker.String.base64(8)
    password = Faker.String.base64(24)
    email = Faker.Nato.letter_code_word() <> "@" <> Faker.Nato.letter_code_word() <> ".com"
    nickname = Faker.Name.name()
    {:ok, account} = Account.create(username, password, email, nickname)

    context |> Map.put(:account, account)
  end

  defp create_token(%{account: account} = context) do
    type = Faker.Nato.letter_code_word()
    {:ok, token} = Token.generate(account, type)

    context |> Map.put(:token, token)
  end
end
