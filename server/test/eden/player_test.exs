defmodule Eden.PlayerTest do
  use Eden.Case
  use Eden.PlayerCase

  alias Eden.Player

  @invalid_attrs %{email: "invalidemail.com", login: "inv", name: "i", password: "short"}

  setup do
    {:ok, %{:player => create_player}}
  end

  test "get player from database", %{:player => player} do
    assert {:ok, _player} = Player.read(player.id)
  end

  test "unable to get player from database because id is bad" do
    assert {:error, _player} = Player.read(Ecto.UUID.generate)
  end

  test "does not verify email when email verification token is invalid" do
    assert {:error, _player} = Player.verify_email("foo")
  end

  test "does not create resource and returns errors when data is invalid" do
    assert {:error, _player} = Player.create(%{})
  end

  test "updates name when data is valid", %{:player => player} do
    assert {:ok, _player} = Player.set(player, "name", "Titanius Anglesmith")
  end

  test "does not update email when data is invalid", %{:player => player} do
    assert {:error, _player} = Player.set(player, :email, "invalid_email_address.com")
  end

  test "login with valid password", %{:player => player} do
    assert {:ok, _player} = Player.authenticate(player.login, "Valid Password")
  end

  test "login with invalid password", %{:player => player} do
    assert {:error, _player} = Player.authenticate(player.login, "Invalid Password")
  end
end