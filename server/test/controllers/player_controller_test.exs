defmodule Eden.PlayerControllerTest do
  import Ecto.Changeset
  use Phoenix.ConnTest
  use Eden.ConnCase
  use Plug.Test
  alias Eden.Player
  alias Eden.Router

  @password "This is a valid passphrase"
  @valid_attrs %{email: nil, email_confirmation: nil, password: @password, password_confirmation: @password, login: nil, name: nil}
  @invalid_attrs %{email: "invalidemailaddress"}

  setup do
    conn = conn() |> put_req_header("accept", "application/json")

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

    {:ok, %{:conn => conn, :player => player}}
  end

  test "lists all entries on index", %{:conn => conn, :player => player} do
    conn = get conn, player_path(conn, :index)
    assert json_response(conn, 200)["data"] != []
  end

  test "shows chosen resource", %{:conn => conn, :player => player} do
    conn = get conn, player_path(conn, :show, player)
    assert json_response(conn, 200)["data"] == %{"id" => player.id,
      "last_login" => player.last_login,
      "name" => player.name,
      "email" => player.email}
  end

  test "does not show resource and instead throw error when id is nonexistent", %{:conn => conn} do
    assert_raise Ecto.NoResultsError, fn ->
      conn
        |> get player_path(conn, :show, -1)
    end
  end
  
  test "does not verify email when email verification token is invalid", %{:conn => conn} do
    conn = post conn, player_path(conn, :verify_email), token:  "not a valid token"
    assert response(conn, 422)
  end

  test "does not create resource and renders errors when data is invalid", %{:conn => conn} do
    conn = post conn, player_path(conn, :create), @valid_attrs
    assert response(conn, 422)
  end

  test "updates name and renders chosen resource when data is valid", %{:conn => conn, :player => player} do
    conn = conn
    |> with_session
    |> put_session(:current_player, player.id)
    |> assign(:current_player, player)

    conn = conn
    |> put player_path(conn, :update, player), %{"name" => "This is a new name"}
    assert json_response(conn, 200)
  end

  test "updates email and renders chosen resource when data is valid", %{:conn => conn, :player => player} do
    conn = conn
    |> with_session
    |> put_session(:current_player, player.id)
    |> assign(:current_player, player)

    conn = conn
    |> put player_path(conn, :update, player), %{"email" => "#{Ecto.UUID.generate}@eden.com"}
    assert json_response(conn, 200)
  end

  test "updates password and renders chosen resource when data is valid", %{:conn => conn, :player => player} do
    conn = conn
    |> with_session
    |> put_session(:current_player, player.id)
    |> assign(:current_player, player)

    conn = conn
    |> put player_path(conn, :update, player), %{"password" => "This is a new valid password", "password_confirmation" => "This is a new valid password"}
    assert json_response(conn, 200)
  end

  test "updates password and renders chosen resource when player is invalid", %{:conn => conn, :player => player} do
    conn = conn
    |> with_session
    |> put_session(:current_player, player.id)
    |> assign(:current_player, player)

    player = %{player | id: -1}

    conn = conn
    |> put player_path(conn, :update, player), %{"password" => "This is a new valid password", "password_confirmation" => "This is a new valid password"}
    assert json_response(conn, 401)
  end

  test "does not update chosen resource and renders errors when data is invalid", %{:conn => conn, :player => player} do
    conn = conn
    |> with_session
    |> put_session(:current_player, player.id)
    |> assign(:current_player, player)

    conn = conn
    |> put player_path(conn, :update, player), %{"email" => "foobar"}
    assert json_response(conn, 422)
  end

  test "logs into an account", %{:conn => conn, :player => player} do
    conn = conn
    |> with_session

    conn = post conn, player_path(conn, :login), %{"login" => player.login, "password" => @password}
    assert conn.status == 200
  end

  test "unsuccessfully logs into an account", %{:conn => conn, :player => player} do
    conn = post conn, player_path(conn, :login), %{"login" => "bad login", "password" => "bad password"}
    assert json_response(conn, 422)
  end

  test "logs out of an account", %{:conn => conn, :player => player} do
    conn = conn
    |> with_session
    |> put_session(:current_player, player.id)
    |> assign(:current_player, player)

    conn = post conn, player_path(conn, :logout), %{"id" => Integer.to_string(player.id)}
    assert conn.status == 200
  end

  test "unsuccessfully logs out of an account since no session exists", %{:conn => conn, :player => player} do
    conn = conn
    |> with_session
    |> put_session(:current_player, player.id)
    |> assign(:current_player, player)

    conn = post conn, player_path(conn, :logout), %{"id" => "-1"}
    assert json_response(conn, 401)
  end

  defp with_session(conn) do
    session_opts = Plug.Session.init(store: :cookie, key: "_app",
                                     encryption_salt: "abc", signing_salt: "abc")
    conn
    |> Map.put(:secret_key_base, String.duplicate("abcdefgh", 8))
    |> Plug.Session.call(session_opts)
    |> Plug.Conn.fetch_session()
  end
end
