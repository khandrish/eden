defmodule Exmud.AccountTest do
  use Exmud.DataCase

  alias Exmud.Account

  describe "users" do
    alias Exmud.Account.User

    @valid_attrs %{email: "some email", email_verified: true, nickname: "some nickname"}
    @update_attrs %{email: "some updated email", email_verified: false, nickname: "some updated nickname"}
    @invalid_attrs %{email: nil, email_verified: nil, nickname: nil}

    def user_fixture(attrs \\ %{}) do
      {:ok, user} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Account.create_user()

      user
    end

    test "list_users/0 returns all users" do
      user = user_fixture()
      assert Account.list_users() == [user]
    end

    test "get_user!/1 returns the user with given id" do
      user = user_fixture()
      assert Account.get_user!(user.id) == user
    end

    test "create_user/1 with valid data creates a user" do
      assert {:ok, %User{} = user} = Account.create_user(@valid_attrs)
      assert user.email == "some email"
      assert user.email_verified == true
      assert user.nickname == "some nickname"
    end

    test "create_user/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Account.create_user(@invalid_attrs)
    end

    test "update_user/2 with valid data updates the user" do
      user = user_fixture()
      assert {:ok, %User{} = user} = Account.update_user(user, @update_attrs)
      assert user.email == "some updated email"
      assert user.email_verified == false
      assert user.nickname == "some updated nickname"
    end

    test "update_user/2 with invalid data returns error changeset" do
      user = user_fixture()
      assert {:error, %Ecto.Changeset{}} = Account.update_user(user, @invalid_attrs)
      assert user == Account.get_user!(user.id)
    end

    test "delete_user/1 deletes the user" do
      user = user_fixture()
      assert {:ok, %User{}} = Account.delete_user(user)
      assert_raise Ecto.NoResultsError, fn -> Account.get_user!(user.id) end
    end

    test "change_user/1 returns a user changeset" do
      user = user_fixture()
      assert %Ecto.Changeset{} = Account.change_user(user)
    end
  end

  describe "username_credentials" do
    alias Exmud.Account.UsernameCredential

    @valid_attrs %{password: "some password", username: "some username"}
    @update_attrs %{password: "some updated password", username: "some updated username"}
    @invalid_attrs %{password: nil, username: nil}

    def username_credential_fixture(attrs \\ %{}) do
      {:ok, username_credential} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Account.create_username_credential()

      username_credential
    end

    test "list_username_credentials/0 returns all username_credentials" do
      username_credential = username_credential_fixture()
      assert Account.list_username_credentials() == [username_credential]
    end

    test "get_username_credential!/1 returns the username_credential with given id" do
      username_credential = username_credential_fixture()
      assert Account.get_username_credential!(username_credential.id) == username_credential
    end

    test "create_username_credential/1 with valid data creates a username_credential" do
      assert {:ok, %UsernameCredential{} = username_credential} = Account.create_username_credential(@valid_attrs)
      assert username_credential.password == "some password"
      assert username_credential.username == "some username"
    end

    test "create_username_credential/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Account.create_username_credential(@invalid_attrs)
    end

    test "update_username_credential/2 with valid data updates the username_credential" do
      username_credential = username_credential_fixture()
      assert {:ok, %UsernameCredential{} = username_credential} = Account.update_username_credential(username_credential, @update_attrs)
      assert username_credential.password == "some updated password"
      assert username_credential.username == "some updated username"
    end

    test "update_username_credential/2 with invalid data returns error changeset" do
      username_credential = username_credential_fixture()
      assert {:error, %Ecto.Changeset{}} = Account.update_username_credential(username_credential, @invalid_attrs)
      assert username_credential == Account.get_username_credential!(username_credential.id)
    end

    test "delete_username_credential/1 deletes the username_credential" do
      username_credential = username_credential_fixture()
      assert {:ok, %UsernameCredential{}} = Account.delete_username_credential(username_credential)
      assert_raise Ecto.NoResultsError, fn -> Account.get_username_credential!(username_credential.id) end
    end

    test "change_username_credential/1 returns a username_credential changeset" do
      username_credential = username_credential_fixture()
      assert %Ecto.Changeset{} = Account.change_username_credential(username_credential)
    end
  end

  describe "email_credentials" do
    alias Exmud.Account.EmailCredential

    @valid_attrs %{password: "some password"}
    @update_attrs %{password: "some updated password"}
    @invalid_attrs %{password: nil}

    def email_credential_fixture(attrs \\ %{}) do
      {:ok, email_credential} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Account.create_email_credential()

      email_credential
    end

    test "list_email_credentials/0 returns all email_credentials" do
      email_credential = email_credential_fixture()
      assert Account.list_email_credentials() == [email_credential]
    end

    test "get_email_credential!/1 returns the email_credential with given id" do
      email_credential = email_credential_fixture()
      assert Account.get_email_credential!(email_credential.id) == email_credential
    end

    test "create_email_credential/1 with valid data creates a email_credential" do
      assert {:ok, %EmailCredential{} = email_credential} = Account.create_email_credential(@valid_attrs)
      assert email_credential.password == "some password"
    end

    test "create_email_credential/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Account.create_email_credential(@invalid_attrs)
    end

    test "update_email_credential/2 with valid data updates the email_credential" do
      email_credential = email_credential_fixture()
      assert {:ok, %EmailCredential{} = email_credential} = Account.update_email_credential(email_credential, @update_attrs)
      assert email_credential.password == "some updated password"
    end

    test "update_email_credential/2 with invalid data returns error changeset" do
      email_credential = email_credential_fixture()
      assert {:error, %Ecto.Changeset{}} = Account.update_email_credential(email_credential, @invalid_attrs)
      assert email_credential == Account.get_email_credential!(email_credential.id)
    end

    test "delete_email_credential/1 deletes the email_credential" do
      email_credential = email_credential_fixture()
      assert {:ok, %EmailCredential{}} = Account.delete_email_credential(email_credential)
      assert_raise Ecto.NoResultsError, fn -> Account.get_email_credential!(email_credential.id) end
    end

    test "change_email_credential/1 returns a email_credential changeset" do
      email_credential = email_credential_fixture()
      assert %Ecto.Changeset{} = Account.change_email_credential(email_credential)
    end
  end

  describe "profiles" do
    alias Exmud.Account.Profile

    @valid_attrs %{email: "some email", email_verified: true, name: "some name", tos_accepted: true, tos_history: []}
    @update_attrs %{email: "some updated email", email_verified: false, name: "some updated name", tos_accepted: false, tos_history: []}
    @invalid_attrs %{email: nil, email_verified: nil, name: nil, tos_accepted: nil, tos_history: nil}

    def profile_fixture(attrs \\ %{}) do
      {:ok, profile} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Account.create_profile()

      profile
    end

    test "list_profiles/0 returns all profiles" do
      profile = profile_fixture()
      assert Account.list_profiles() == [profile]
    end

    test "get_profile!/1 returns the profile with given id" do
      profile = profile_fixture()
      assert Account.get_profile!(profile.id) == profile
    end

    test "create_profile/1 with valid data creates a profile" do
      assert {:ok, %Profile{} = profile} = Account.create_profile(@valid_attrs)
      assert profile.email == "some email"
      assert profile.email_verified == true
      assert profile.name == "some name"
      assert profile.tos_accepted == true
      assert profile.tos_history == []
    end

    test "create_profile/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Account.create_profile(@invalid_attrs)
    end

    test "update_profile/2 with valid data updates the profile" do
      profile = profile_fixture()
      assert {:ok, %Profile{} = profile} = Account.update_profile(profile, @update_attrs)
      assert profile.email == "some updated email"
      assert profile.email_verified == false
      assert profile.name == "some updated name"
      assert profile.tos_accepted == false
      assert profile.tos_history == []
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

  describe "identities" do
    alias Exmud.Account.Identity

    @valid_attrs %{data: "some data", key: "some key", type: "some type"}
    @update_attrs %{data: "some updated data", key: "some updated key", type: "some updated type"}
    @invalid_attrs %{data: nil, key: nil, type: nil}

    def identity_fixture(attrs \\ %{}) do
      {:ok, identity} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Account.create_identity()

      identity
    end

    test "list_identities/0 returns all identities" do
      identity = identity_fixture()
      assert Account.list_identities() == [identity]
    end

    test "get_identity!/1 returns the identity with given id" do
      identity = identity_fixture()
      assert Account.get_identity!(identity.id) == identity
    end

    test "create_identity/1 with valid data creates a identity" do
      assert {:ok, %Identity{} = identity} = Account.create_identity(@valid_attrs)
      assert identity.data == "some data"
      assert identity.key == "some key"
      assert identity.type == "some type"
    end

    test "create_identity/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Account.create_identity(@invalid_attrs)
    end

    test "update_identity/2 with valid data updates the identity" do
      identity = identity_fixture()
      assert {:ok, %Identity{} = identity} = Account.update_identity(identity, @update_attrs)
      assert identity.data == "some updated data"
      assert identity.key == "some updated key"
      assert identity.type == "some updated type"
    end

    test "update_identity/2 with invalid data returns error changeset" do
      identity = identity_fixture()
      assert {:error, %Ecto.Changeset{}} = Account.update_identity(identity, @invalid_attrs)
      assert identity == Account.get_identity!(identity.id)
    end

    test "delete_identity/1 deletes the identity" do
      identity = identity_fixture()
      assert {:ok, %Identity{}} = Account.delete_identity(identity)
      assert_raise Ecto.NoResultsError, fn -> Account.get_identity!(identity.id) end
    end

    test "change_identity/1 returns a identity changeset" do
      identity = identity_fixture()
      assert %Ecto.Changeset{} = Account.change_identity(identity)
    end
  end
end
