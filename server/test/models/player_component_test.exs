defmodule Eden.PlayerComponentTest do
  use Eden.ModelCase

  alias Eden.PlayerComponent

  @valid_attrs %{email: "valid@email.com", login: "somebscontent", name: "some content", password: "foobarfoobar", password_confirmation: "foobarfoobar"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = PlayerComponent.changeset(:create, %PlayerComponent{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = PlayerComponent.changeset(:create, %PlayerComponent{}, @invalid_attrs)
    refute changeset.valid?
  end
end
