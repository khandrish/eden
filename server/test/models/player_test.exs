defmodule Eden.PlayerTest do
  use Eden.ModelCase

  alias Eden.Player

  @invalid_attrs 

  test "changeset with valid attributes" do
    p = %{email: "valid@email.com", login: "somebscontent", name: "some content", password: "foobarfoobar"}
    Player.new(p)
  end
end