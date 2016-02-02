defmodule Eden.PlayerLockTest do
  use Eden.ModelCase

  alias Eden.PlayerLock

  @valid_attrs %{duration: "some content", reason: "some content", type: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    lock = %PlayerLock{created_by: Ecto.UUID.generate, last_modified_by: Ecto.UUID.generate, player_id: Ecto.UUID.generate}
    changeset = PlayerLock.changeset(:create, lock, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = PlayerLock.changeset(:create, %PlayerLock{}, @invalid_attrs)
    refute changeset.valid?
  end
end
