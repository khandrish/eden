defmodule Eden.PlayerLockTest do
  use Eden.ModelCase

  alias Eden.PlayerLock

  @valid_attrs %{created_by: 42, duration: "some content", last_modified_by: 42, player_id: 42, reason: "some content", type: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = PlayerLock.changeset(:create, %PlayerLock{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = PlayerLock.changeset(:create, %PlayerLock{}, @invalid_attrs)
    refute changeset.valid?
  end
end
