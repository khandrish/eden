defmodule Eden.EntityTest do
  use Eden.ModelCase

  alias Eden.Entity

  @valid_attrs %{}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Entity.changeset(%Entity{}, @valid_attrs)
    assert changeset.valid?
  end
end
