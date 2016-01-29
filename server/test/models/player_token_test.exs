defmodule Eden.PlayerTokenTest do
  use Eden.ModelCase

  alias Eden.PlayerToken

  @valid_attrs %{expiry: "some content", player_id: 42, token: "some content", type: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = PlayerToken.changeset(%PlayerToken{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = PlayerToken.changeset(%PlayerToken{}, @invalid_attrs)
    refute changeset.valid?
  end
end
