defmodule Eden.PlayerTokenTest do
  use Eden.ModelCase

  alias Eden.PlayerToken

  test "changeset with valid attributes" do
    changeset = PlayerToken.new(%{expiry: "some content", player_id: Ecto.UUID.generate, type: "some content"})
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = PlayerToken.new(%{})
    refute changeset.valid?
  end
end
