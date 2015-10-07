defmodule Eden.TokenControllerTest do
  use Eden.ConnCase

  test "GET /api/token while unauthenticated" do
    conn = get conn(), "/api/sandbox/token"
    assert 401 === conn.status
  end
end
