defmodule Eden.CharacterChannelTest do
  use Eden.ChannelCase
  import Ecto.Changeset
  import Phoenix.Socket
  alias Eden.CharacterChannel
  alias Eden.Player

  @password "This is a valid passphrase"
  @valid_attrs %{email: nil, email_confirmation: nil, password: @password, password_confirmation: @password, login: nil, name: nil}

  setup do
    email = "#{Ecto.UUID.generate}@eden.com"
    login = Ecto.UUID.generate
    name = Ecto.UUID.generate

    attrs = @valid_attrs
    |> Map.put(:email, email)
    |> Map.put(:login, login)
    |> Map.put(:name, name)

    changeset = Player.changeset(:create, %Player{}, attrs)
    |> force_change(:hash, Comeonin.Bcrypt.hashpwsalt(@password))

    player = Repo.insert! changeset

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
