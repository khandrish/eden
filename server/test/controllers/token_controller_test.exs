defmodule Eden.TokenControllerTest do
  use Eden.ConnCase

  test "GET /token" do
    conn = get conn(), "/token"
    assert 200 === conn.status
  end
end
