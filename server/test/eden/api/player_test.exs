defmodule Eden.Api.PlayerTest do
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

  test "create player", %{socket: socket} do
    params = %{
      :login => "#{Ecto.UUID.generate}",
      :password => "Valid Password",
      :email => "#{Ecto.UUID.generate}@eden.com",
      :name => "#{Ecto.UUID.generate}"
    }
    ref = push socket, "player:create", params
    assert_reply ref, :ok, %{"data" => _player}
  end

  test "fail to create player", %{socket: socket} do
    ref = push socket, "player:create"
    assert_reply ref, :error, %{"data" => "Unable to create player"}
  end

  test "delete player", %{socket: socket} do
    player = create_player
    ref = push socket, "player:delete", %{"id" => player.id}
    assert_reply ref, :ok, %{"data" => _player}
  end

  test "fail to delete player", %{socket: socket} do
    ref = push socket, "player:delete", %{"id" => "oof"}
    assert_reply ref, :error, %{"data" => "Unable to delete player"}
  end
end