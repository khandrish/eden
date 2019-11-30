defmodule Exmud.EngineTest do
  use Exmud.DataCase

  alias Exmud.Engine

  describe "muds" do
    alias Exmud.Account

    @valid_player_attrs %{status: Account.Constants.PlayerStatus.created(), tos_accepted: false}

    def player_fixture(attrs \\ %{}) do
      {:ok, player} =
        attrs
        |> Enum.into(@valid_player_attrs)
        |> Account.create_player()

      player
    end

    alias Exmud.Engine.Mud

    @valid_mud_attrs %{description: "This is a description", name: "Name"}
    @update_mud_attrs %{description: "This is a new description", name: "New Name"}
    @invalid_mud_attrs %{description: nil, name: nil}

    def mud_fixture(attrs \\ %{}) do
      player = player_fixture()

      {:ok, mud} =
        attrs
        |> Enum.into(@valid_mud_attrs)
        |> Map.put(:player_id, player.id)
        |> Engine.create_mud()

      mud
    end

    test "list_muds/0 returns all muds" do
      mud = mud_fixture()
      {:ok, [returned_mud]} = Engine.list_muds()
      assert returned_mud == mud
    end

    test "get_mud!/1 returns the mud with given id" do
      mud = mud_fixture()
      assert Engine.get_mud!(mud.id) == mud
    end

    test "create_mud/1 with valid data creates a mud" do
      assert {:ok, %Mud{} = mud} = Engine.create_mud(@valid_mud_attrs)
      assert mud.name == "Name"
      assert mud.description == "This is a description"
    end

    test "create_mud/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Engine.create_mud(@invalid_mud_attrs)
    end

    test "update_mud/2 with valid data updates the mud" do
      mud = mud_fixture()
      assert {:ok, %Mud{} = mud} = Engine.update_mud(mud, @update_mud_attrs)
      assert mud.name == "New Name"
      assert mud.description == "This is a new description"
    end

    test "update_mud/2 with invalid data returns error changeset" do
      mud = mud_fixture()
      assert {:error, %Ecto.Changeset{}} = Engine.update_mud(mud, @invalid_mud_attrs)
      assert mud == Engine.get_mud!(mud.id)
    end

    test "delete_mud/1 deletes the mud" do
      mud = mud_fixture()
      assert {:ok, %Mud{}} = Engine.delete_mud(mud)
      assert_raise Ecto.NoResultsError, fn -> Engine.get_mud!(mud.id) end
    end
  end

  describe "characters" do
    alias Exmud.Engine.Character

    @valid_attrs %{name: "some name"}

    @update_attrs %{name: "some updated name"}

    @invalid_attrs %{name: nil}

    def character_fixture(attrs \\ %{}) do
      player = player_fixture()
      mud = mud_fixture()

      {:ok, character} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Enum.into(%{mud_id: mud.id, player_id: player.id})
        |> Engine.create_character()

      character
    end

    test "list_characters/0 returns all characters" do
      character = character_fixture()
      assert Engine.list_characters() == {:ok, [character]}
    end

    test "get_character!/1 returns the character with given id" do
      character = character_fixture()
      assert Engine.get_character_by_id!(character.id) == character
    end

    test "create_character/1 with valid data creates a character" do
      player = player_fixture()
      mud = mud_fixture()

      attrs = Enum.into(@valid_attrs, %{mud_id: mud.id, player_id: player.id})

      assert {:ok, %Character{} = character} = Engine.create_character(attrs)
      assert character.name == "some name"
    end

    test "create_character/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Engine.create_character(@invalid_attrs)
    end

    test "update_character/2 with valid data updates the character" do
      character = character_fixture()
      assert {:ok, %Character{} = character} = Engine.update_character(character, @update_attrs)
      assert character.name == "some updated name"
    end

    test "update_character/2 with invalid data returns error changeset" do
      character = character_fixture()
      assert {:error, %Ecto.Changeset{}} = Engine.update_character(character, @invalid_attrs)
      assert character == Engine.get_character_by_id!(character.id)
    end

    test "delete_character/1 deletes the character" do
      character = character_fixture()
      assert {:ok, %Character{}} = Engine.delete_character(character)
      assert_raise Ecto.NoResultsError, fn -> Engine.get_character_by_id!(character.id) end
    end
  end
end
