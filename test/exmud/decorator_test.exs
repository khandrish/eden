defmodule Exmud.DecoratorTest do
  use Exmud.DataCase

  alias Exmud.Decorator

  describe "decorator_categories" do
    alias Exmud.Decorator.DecoratorCategory

    @valid_attrs %{name: "some name"}
    @update_attrs %{name: "some updated name"}
    @invalid_attrs %{name: nil}

    def decorator_category_fixture(attrs \\ %{}) do
      {:ok, decorator_category} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Decorator.create_decorator_category()

      decorator_category
    end

    test "list_decorator_categories/0 returns all decorator_categories" do
      decorator_category = decorator_category_fixture()
      assert Decorator.list_decorator_categories() == [decorator_category]
    end

    test "get_decorator_category!/1 returns the decorator_category with given id" do
      decorator_category = decorator_category_fixture()
      assert Decorator.get_decorator_category!(decorator_category.id) == decorator_category
    end

    test "create_decorator_category/1 with valid data creates a decorator_category" do
      assert {:ok, %DecoratorCategory{} = decorator_category} = Decorator.create_decorator_category(@valid_attrs)
      assert decorator_category.name == "some name"
    end

    test "create_decorator_category/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Decorator.create_decorator_category(@invalid_attrs)
    end

    test "update_decorator_category/2 with valid data updates the decorator_category" do
      decorator_category = decorator_category_fixture()
      assert {:ok, %DecoratorCategory{} = decorator_category} = Decorator.update_decorator_category(decorator_category, @update_attrs)
      assert decorator_category.name == "some updated name"
    end

    test "update_decorator_category/2 with invalid data returns error changeset" do
      decorator_category = decorator_category_fixture()
      assert {:error, %Ecto.Changeset{}} = Decorator.update_decorator_category(decorator_category, @invalid_attrs)
      assert decorator_category == Decorator.get_decorator_category!(decorator_category.id)
    end

    test "delete_decorator_category/1 deletes the decorator_category" do
      decorator_category = decorator_category_fixture()
      assert {:ok, %DecoratorCategory{}} = Decorator.delete_decorator_category(decorator_category)
      assert_raise Ecto.NoResultsError, fn -> Decorator.get_decorator_category!(decorator_category.id) end
    end

    test "change_decorator_category/1 returns a decorator_category changeset" do
      decorator_category = decorator_category_fixture()
      assert %Ecto.Changeset{} = Decorator.change_decorator_category(decorator_category)
    end
  end

  describe "decorator_types" do
    alias Exmud.Decorator.DecoratorType

    @valid_attrs %{name: "some name"}
    @update_attrs %{name: "some updated name"}
    @invalid_attrs %{name: nil}

    def decorator_type_fixture(attrs \\ %{}) do
      {:ok, decorator_type} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Decorator.create_decorator_type()

      decorator_type
    end

    test "list_decorator_types/0 returns all decorator_types" do
      decorator_type = decorator_type_fixture()
      assert Decorator.list_decorator_types() == [decorator_type]
    end

    test "get_decorator_type!/1 returns the decorator_type with given id" do
      decorator_type = decorator_type_fixture()
      assert Decorator.get_decorator_type!(decorator_type.id) == decorator_type
    end

    test "create_decorator_type/1 with valid data creates a decorator_type" do
      assert {:ok, %DecoratorType{} = decorator_type} = Decorator.create_decorator_type(@valid_attrs)
      assert decorator_type.name == "some name"
    end

    test "create_decorator_type/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Decorator.create_decorator_type(@invalid_attrs)
    end

    test "update_decorator_type/2 with valid data updates the decorator_type" do
      decorator_type = decorator_type_fixture()
      assert {:ok, %DecoratorType{} = decorator_type} = Decorator.update_decorator_type(decorator_type, @update_attrs)
      assert decorator_type.name == "some updated name"
    end

    test "update_decorator_type/2 with invalid data returns error changeset" do
      decorator_type = decorator_type_fixture()
      assert {:error, %Ecto.Changeset{}} = Decorator.update_decorator_type(decorator_type, @invalid_attrs)
      assert decorator_type == Decorator.get_decorator_type!(decorator_type.id)
    end

    test "delete_decorator_type/1 deletes the decorator_type" do
      decorator_type = decorator_type_fixture()
      assert {:ok, %DecoratorType{}} = Decorator.delete_decorator_type(decorator_type)
      assert_raise Ecto.NoResultsError, fn -> Decorator.get_decorator_type!(decorator_type.id) end
    end

    test "change_decorator_type/1 returns a decorator_type changeset" do
      decorator_type = decorator_type_fixture()
      assert %Ecto.Changeset{} = Decorator.change_decorator_type(decorator_type)
    end
  end
end
