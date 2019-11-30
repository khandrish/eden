defmodule ExmudWeb.PlayerControllerTest do
  use ExmudWeb.ConnCase

  alias Exmud.Account
  alias Exmud.Account.Player

  @create_attrs %{
    status: Exmud.Account.Constants.PlayerStatus.pending(),
    tos_accepted: false
  }
  @update_attrs %{
    status: Exmud.Account.Constants.PlayerStatus.created(),
    tos_accepted: true
  }
  @invalid_attrs %{
    status: nil,
    tos_accepted: nil
  }

  def fixture(:player) do
    {:ok, player} = Account.create_player(@create_attrs)
    player
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  # describe "index" do
  #   test "lists all players", %{conn: conn} do
  #     conn =
  #       conn
  #       |> Plug.Test.init_test_session(%{player: fixture(:player)})
  #       |> get(Routes.player_path(conn, :index))

  #     response = json_response(conn, 200)["data"]
  #     assert length(response) == 1
  #   end
  # end

  describe "create player" do
    test "renders player when data is valid", %{conn: conn} do
      conn =
        conn
        |> Plug.Test.init_test_session(%{player: fixture(:player)})
        |> post(Routes.player_path(conn, :create), params: @create_attrs)

      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = post(conn, Routes.player_path(conn, :get), id: id)

      assert %{
               "id" => id
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn =
        conn
        |> Plug.Test.init_test_session(%{player: fixture(:player)})
        |> post(Routes.player_path(conn, :create), params: @invalid_attrs)

      assert json_response(conn, 422)["errors"] != %{}
    end

    test "cannot create a player when not logged in", %{conn: conn} do
      conn = post(conn, Routes.player_path(conn, :create), params: @create_attrs)

      assert json_response(conn, 401)["body"] == nil
    end
  end

  describe "update player" do
    setup [:create_player]

    test "renders player when data is valid", %{conn: conn, player: %Player{id: id} = player} do
      conn =
        conn
        |> Plug.Test.init_test_session(%{player: player})
        |> post(Routes.player_path(conn, :update), id: player.id, params: @update_attrs)

      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = post(conn, Routes.player_path(conn, :get), id: id)

      assert %{
               "id" => id
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, player: player} do
      conn =
        conn
        |> Plug.Test.init_test_session(%{player: player})
        |> post(Routes.player_path(conn, :update), id: player.id, params: @invalid_attrs)

      assert json_response(conn, 422)["errors"] != %{}
    end

    test "cannot update a player when not logged in", %{conn: conn} do
      conn = post(conn, Routes.player_path(conn, :update), params: @update_attrs)

      assert json_response(conn, 401)["body"] == nil
    end
  end

  describe "delete player" do
    setup [:create_player]

    test "deletes chosen player", %{conn: conn, player: player} do
      conn =
        conn
        |> Plug.Test.init_test_session(%{player: player})
        |> post(Routes.player_path(conn, :delete), id: player.id)

      assert response(conn, 204)

      assert_error_sent 404, fn ->
        post(conn, Routes.player_path(conn, :get), id: player.id)
      end
    end

    test "cannot delete a player when not logged in", %{conn: conn, player: player} do
      conn = post(conn, Routes.player_path(conn, :delete), player: player)

      assert json_response(conn, 401)["body"] == nil
    end
  end

  defp create_player(_) do
    player = fixture(:player)
    {:ok, player: player}
  end
end
