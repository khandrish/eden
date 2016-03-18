defmodule Eden.ApiChannelTest do
  require Logger
  use Eden.ChannelCase
  use Eden.PlayerCase

  alias Eden.ApiChannel

  setup do
    token = Phoenix.Token.sign(Eden.Endpoint, "session token", Ecto.UUID.generate)
    {:ok, _, socket} =
      socket()
      |> subscribe_and_join(ApiChannel, "api:v1", %{:token => token})

    {:ok, %{socket: socket, token: token}}
  end

  test "ping replies with status ok", %{socket: socket} do
    ref = push socket, "ping", %{"hello" => "there"}
    assert_reply ref, :ok
  end

  test "session auth", %{socket: socket} do
    player = create_player
    ref = push socket, "session:authenticate", %{:login => player.login, :password => "Valid Password"}
    assert_reply ref, :ok
    ref = push socket, "session:is_authenticated"
    assert_reply ref, :ok, %{"data" => true}
    ref = push socket, "session:repudiate", %{}
    assert_reply ref, :ok
    ref = push socket, "session:is_authenticated"
    assert_reply ref, :ok, %{"data" => false}
  end

  test "reuse session", %{socket: socket, token: token} do
    Process.unlink(socket.channel_pid)
    player = create_player
    ref = push socket, "session:authenticate", %{:login => player.login, :password => "Valid Password"}
    assert_reply ref, :ok
    ref = push socket, "session:is_authenticated"
    assert_reply ref, :ok, %{"data" => true}
    
    leave socket
    Logger.debug "LEFT SOCKET"
    {:ok, _, socket} =
      socket()
      |> subscribe_and_join(ApiChannel, "api:v1", %{:token => token})
    ref = push socket, "session:is_authenticated"
    assert_reply ref, :ok, %{"data" => true}
  end

  test "invalid operations", %{socket: socket} do
    ref = push socket, "foo"
    assert_reply ref, :error, %{"data" => "Invalid operation"}
    ref = push socket, "session:foo"
    assert_reply ref, :error, %{"data" => "Invalid operation"}
  end
end