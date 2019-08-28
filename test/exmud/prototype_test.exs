defmodule Exmud.PrototypeTest do
  use Exmud.DataCase

  alias Exmud.Prototype

  describe "prototypes" do
    alias Exmud.Prototype.Prototype

    @valid_attrs %{name: "some name"}
    @update_attrs %{name: "some updated name"}
    @invalid_attrs %{name: nil}

    def prototype_fixture(attrs \\ %{}) do
      {:ok, prototype} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Prototype.create_prototype()

      prototype
    end

    test "list_prototypes/0 returns all prototypes" do
      prototype = prototype_fixture()
      assert Prototype.list_prototypes() == [prototype]
    end

    test "get_prototype!/1 returns the prototype with given id" do
      prototype = prototype_fixture()
      assert Prototype.get_prototype!(prototype.id) == prototype
    end

    test "create_prototype/1 with valid data creates a prototype" do
      assert {:ok, %Prototype{} = prototype} = Prototype.create_prototype(@valid_attrs)
      assert prototype.name == "some name"
    end

    test "create_prototype/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Prototype.create_prototype(@invalid_attrs)
    end

    test "update_prototype/2 with valid data updates the prototype" do
      prototype = prototype_fixture()

      assert {:ok, %Prototype{} = prototype} =
               Prototype.update_prototype(prototype, @update_attrs)

      assert prototype.name == "some updated name"
    end

    test "update_prototype/2 with invalid data returns error changeset" do
      prototype = prototype_fixture()
      assert {:error, %Ecto.Changeset{}} = Prototype.update_prototype(prototype, @invalid_attrs)
      assert prototype == Prototype.get_prototype!(prototype.id)
    end

    test "delete_prototype/1 deletes the prototype" do
      prototype = prototype_fixture()
      assert {:ok, %Prototype{}} = Prototype.delete_prototype(prototype)
      assert_raise Ecto.NoResultsError, fn -> Prototype.get_prototype!(prototype.id) end
    end

    test "change_prototype/1 returns a prototype changeset" do
      prototype = prototype_fixture()
      assert %Ecto.Changeset{} = Prototype.change_prototype(prototype)
    end
  end

  describe "prototype_categories" do
    alias Exmud.Prototype.PrototypeCategory

    @valid_attrs %{name: "some name"}
    @update_attrs %{name: "some updated name"}
    @invalid_attrs %{name: nil}

    def prototype_category_fixture(attrs \\ %{}) do
      {:ok, prototype_category} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Prototype.create_prototype_category()

      prototype_category
    end

    test "list_prototype_categories/0 returns all prototype_categories" do
      prototype_category = prototype_category_fixture()
      assert Prototype.list_prototype_categories() == [prototype_category]
    end

    test "get_prototype_category!/1 returns the prototype_category with given id" do
      prototype_category = prototype_category_fixture()
      assert Prototype.get_prototype_category!(prototype_category.id) == prototype_category
    end

    test "create_prototype_category/1 with valid data creates a prototype_category" do
      assert {:ok, %PrototypeCategory{} = prototype_category} = Prototype.create_prototype_category(@valid_attrs)
      assert prototype_category.name == "some name"
    end

    test "create_prototype_category/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Prototype.create_prototype_category(@invalid_attrs)
    end

    test "update_prototype_category/2 with valid data updates the prototype_category" do
      prototype_category = prototype_category_fixture()
      assert {:ok, %PrototypeCategory{} = prototype_category} = Prototype.update_prototype_category(prototype_category, @update_attrs)
      assert prototype_category.name == "some updated name"
    end

    test "update_prototype_category/2 with invalid data returns error changeset" do
      prototype_category = prototype_category_fixture()
      assert {:error, %Ecto.Changeset{}} = Prototype.update_prototype_category(prototype_category, @invalid_attrs)
      assert prototype_category == Prototype.get_prototype_category!(prototype_category.id)
    end

    test "delete_prototype_category/1 deletes the prototype_category" do
      prototype_category = prototype_category_fixture()
      assert {:ok, %PrototypeCategory{}} = Prototype.delete_prototype_category(prototype_category)
      assert_raise Ecto.NoResultsError, fn -> Prototype.get_prototype_category!(prototype_category.id) end
    end

    test "change_prototype_category/1 returns a prototype_category changeset" do
      prototype_category = prototype_category_fixture()
      assert %Ecto.Changeset{} = Prototype.change_prototype_category(prototype_category)
    end
  end

  describe "prototype_types" do
    alias Exmud.Prototype.PrototypeType

    @valid_attrs %{name: "some name"}
    @update_attrs %{name: "some updated name"}
    @invalid_attrs %{name: nil}

    def prototype_type_fixture(attrs \\ %{}) do
      {:ok, prototype_type} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Prototype.create_prototype_type()

      prototype_type
    end

    test "list_prototype_types/0 returns all prototype_types" do
      prototype_type = prototype_type_fixture()
      assert Prototype.list_prototype_types() == [prototype_type]
    end

    test "get_prototype_type!/1 returns the prototype_type with given id" do
      prototype_type = prototype_type_fixture()
      assert Prototype.get_prototype_type!(prototype_type.id) == prototype_type
    end

    test "create_prototype_type/1 with valid data creates a prototype_type" do
      assert {:ok, %PrototypeType{} = prototype_type} = Prototype.create_prototype_type(@valid_attrs)
      assert prototype_type.name == "some name"
    end

    test "create_prototype_type/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Prototype.create_prototype_type(@invalid_attrs)
    end

    test "update_prototype_type/2 with valid data updates the prototype_type" do
      prototype_type = prototype_type_fixture()
      assert {:ok, %PrototypeType{} = prototype_type} = Prototype.update_prototype_type(prototype_type, @update_attrs)
      assert prototype_type.name == "some updated name"
    end

    test "update_prototype_type/2 with invalid data returns error changeset" do
      prototype_type = prototype_type_fixture()
      assert {:error, %Ecto.Changeset{}} = Prototype.update_prototype_type(prototype_type, @invalid_attrs)
      assert prototype_type == Prototype.get_prototype_type!(prototype_type.id)
    end

    test "delete_prototype_type/1 deletes the prototype_type" do
      prototype_type = prototype_type_fixture()
      assert {:ok, %PrototypeType{}} = Prototype.delete_prototype_type(prototype_type)
      assert_raise Ecto.NoResultsError, fn -> Prototype.get_prototype_type!(prototype_type.id) end
    end

    test "change_prototype_type/1 returns a prototype_type changeset" do
      prototype_type = prototype_type_fixture()
      assert %Ecto.Changeset{} = Prototype.change_prototype_type(prototype_type)
    end
  end
end
