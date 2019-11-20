defmodule Exmud.AccountTest do
  use Exmud.DataCase

  alias Exmud.Account

  describe "players" do
    alias Exmud.Account
    alias Exmud.Account.Player

    @valid_attrs %{status: Account.Constants.PlayerStatus.pending(), tos_accepted: false}
    @update_attrs %{status: Account.Constants.PlayerStatus.created(), tos_accepted: true}
    @invalid_attrs %{status: nil, tos_accepted: nil}

    def player_fixture(attrs \\ %{}) do
      {:ok, player} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Account.create_player()

      player
    end

    test "list_players/0 returns all players" do
      player = player_fixture()
      {:ok, [returned_player]} = Account.list_players()
      assert returned_player == Map.put(player, :profile, nil)
    end

    test "get_player!/1 returns the player with given id" do
      player = player_fixture()
      assert Account.get_player!(player.id) == player
    end

    test "create_player/1 with valid data creates a player" do
      assert {:ok, %Player{} = player} = Account.create_player(@valid_attrs)
      assert player.status == Account.Constants.PlayerStatus.pending()
      assert player.tos_accepted == false
    end

    test "create_player/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Account.create_player(@invalid_attrs)
    end

    test "update_player/2 with valid data updates the player" do
      player = player_fixture()
      assert {:ok, %Player{} = player} = Account.update_player(player, @update_attrs)
      assert player.status == Account.Constants.PlayerStatus.created()
      assert player.tos_accepted == true
    end

    test "update_player/2 with invalid data returns error changeset" do
      player = player_fixture()
      assert {:error, %Ecto.Changeset{}} = Account.update_player(player, @invalid_attrs)
      assert player == Account.get_player!(player.id)
    end

    test "delete_player/1 deletes the player" do
      player = player_fixture()
      assert {:ok, %Player{}} = Account.delete_player(player)
      assert_raise Ecto.NoResultsError, fn -> Account.get_player!(player.id) end
    end
  end

  describe "profiles" do
    alias Exmud.Account.Profile

    @valid_attrs %{
      email: "some@email",
      email_verified: true,
      nickname: "some name",
      player_id: nil
    }
    @update_attrs %{
      email: "some@updated.email",
      email_verified: false,
      nickname: "some updated name"
    }
    @invalid_attrs %{email: nil, email_verified: nil, nickname: nil, player_id: nil}

    def profile_fixture(attrs \\ %{}) do
      player = player_fixture()
      {:ok, profile} =
        attrs
        |> Enum.into(%{player_id: player.id})
        |> Enum.into(@valid_attrs)
        |> Account.create_profile()

      profile
    end

    test "list_profiles/0 returns all profiles" do
      profile = profile_fixture()
      assert Account.list_profiles() == {:ok, [profile]}
    end

    test "get_profile!/1 returns the profile with given id" do
      profile = profile_fixture()
      assert Account.get_profile!(profile.id) == profile
    end

    test "create_profile/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Account.create_profile(@invalid_attrs)
    end

    test "update_profile/2 with valid data updates the profile" do
      profile = profile_fixture()
      assert {:ok, %Profile{} = profile} = Account.update_profile(profile, @update_attrs)
      assert profile.email == "some@updated.email"
      assert profile.email_verified == false
      assert profile.nickname == "some updated name"
    end

    test "update_profile/2 with invalid data returns error changeset" do
      profile = profile_fixture()
      assert {:error, %Ecto.Changeset{}} = Account.update_profile(profile, @invalid_attrs)
      assert profile == Account.get_profile!(profile.id)
    end

    test "delete_profile/1 deletes the profile" do
      profile = profile_fixture()
      assert {:ok, %Profile{}} = Account.delete_profile(profile)
      assert_raise Ecto.NoResultsError, fn -> Account.get_profile!(profile.id) end
    end

    test "change_profile/1 returns a profile changeset" do
      profile = profile_fixture()
      assert %Ecto.Changeset{} = Account.change_profile(profile)
    end
  end
end
