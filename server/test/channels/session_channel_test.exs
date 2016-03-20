defmodule Eden.SessionChannelTest do
  use Eden.ChannelCase

  alias Eden.SessionChannel

  setup do
    uuid = Ecto.UUID.generate
    token = Phoenix.Token.sign(Eden.Endpoint, "session_token", uuid)
    {:ok, _, socket} =
      socket()
      |> subscribe_and_join(SessionChannel, "session:#{uuid}", %{token: token})

    {:ok, %{socket: socket, token: token, session_id: uuid}}
  end

  test "ping replies with status ok", %{socket: socket} do
    ref = push socket, "ping", %{"hello" => "there"}
    assert_reply ref, :ok, %{data: "pong"}
  end

  test "broadcasts are pushed to the client", %{socket: socket} do
    broadcast_from! socket, "broadcast", %{"some" => "data"}
    assert_push "broadcast", %{"some" => "data"}
  end
end
