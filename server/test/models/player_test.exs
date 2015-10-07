defmodule Eden.PlayerTest do
  use Eden.ModelCase

  alias Eden.Player

  @valid_attrs %{email: "valid@email.com", login: "somebscontent", name: "some content", password: "foobarfoobar", password_confirmation: "foobarfoobar"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Player.changeset(:create, %Player{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Player.changeset(:create, %Player{}, @invalid_attrs)
    refute changeset.valid?
  end
end