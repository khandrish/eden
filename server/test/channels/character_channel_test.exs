defmodule Eden.CharacterChannelTest do
  use Eden.ChannelCase
  import Ecto.Changeset
  import Phoenix.Socket
  import Pipe
  alias Eden.CharacterChannel
  alias Eden.Player

  @password "This is a valid passphrase"
  @valid_attrs 

  setup do
    params = %{ email: "#{Ecto.UUID.generate}@eden.com",
                password: Ecto.UUID.generate,
                login: Ecto.UUID.generate,
                name: Ecto.UUID.generate}

    {:ok, player} = Player.create(params)

    on_exit fn ->
      Repo.delete! player
    end

    {:ok, _, socket} =
      socket()
      |> assign(:player, player)
      |> subscribe_and_join(CharacterChannel, "characters:#{player.name}")

    {:ok, socket: socket}
  end

  test "ping replies with status ok", %{socket: socket} do
    ref = push socket, "ping", %{"hello" => "there"}
    assert_reply ref, :ok, %{"hello" => "there"}
  end

  test "shout broadcasts to characters:lobby", %{socket: socket} do
    push socket, "shout", %{"hello" => "all"}
    assert_broadcast "shout", %{"hello" => "all"}
  end

  test "broadcasts are pushed to the client", %{socket: socket} do
    broadcast_from! socket, "broadcast", %{"some" => "data"}
    assert_push "broadcast", %{"some" => "data"}
  end
end
