defmodule Exmud.BuilderTest do
  use Exmud.DataCase

  alias Exmud.Builder

  describe "categories" do
    alias Exmud.Builder.Category

    @valid_attrs %{name: "some name"}
    @update_attrs %{name: "some updated name"}
    @invalid_attrs %{name: nil}

    def category_fixture(attrs \\ %{}) do
      {:ok, category} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Builder.create_category()

      category
    end

    test "list_categories/0 returns all categories" do
      category = category_fixture()
      assert Builder.list_categories() == [category]
    end

    test "get_category!/1 returns the category with given id" do
      category = category_fixture()
      assert Builder.get_category!(category.id) == category
    end

    test "create_category/1 with valid data creates a category" do
      assert {:ok, %Category{} = category} = Builder.create_category(@valid_attrs)
      assert category.name == "some name"
    end

    test "create_category/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Builder.create_category(@invalid_attrs)
    end

    test "update_category/2 with valid data updates the category" do
      category = category_fixture()
      assert {:ok, %Category{} = category} = Builder.update_category(category, @update_attrs)
      assert category.name == "some updated name"
    end

    test "update_category/2 with invalid data returns error changeset" do
      category = category_fixture()
      assert {:error, %Ecto.Changeset{}} = Builder.update_category(category, @invalid_attrs)
      assert category == Builder.get_category!(category.id)
    end

    test "delete_category/1 deletes the category" do
      category = category_fixture()
      assert {:ok, %Category{}} = Builder.delete_category(category)
      assert_raise Ecto.NoResultsError, fn -> Builder.get_category!(category.id) end
    end

    test "change_category/1 returns a category changeset" do
      category = category_fixture()
      assert %Ecto.Changeset{} = Builder.change_category(category)
    end
  end

  describe "categories" do
    alias Exmud.Builder.Template

    @valid_attrs %{name: "some name"}
    @update_attrs %{name: "some updated name"}
    @invalid_attrs %{name: nil}

    def template_fixture(attrs \\ %{}) do
      {:ok, template} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Builder.create_template()

      template
    end

    test "list_categories/0 returns all categories" do
      template = template_fixture()
      assert Builder.list_categories() == [template]
    end

    test "get_template!/1 returns the template with given id" do
      template = template_fixture()
      assert Builder.get_template!(template.id) == template
    end

    test "create_template/1 with valid data creates a template" do
      assert {:ok, %Template{} = template} = Builder.create_template(@valid_attrs)
      assert template.name == "some name"
    end

    test "create_template/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Builder.create_template(@invalid_attrs)
    end

    test "update_template/2 with valid data updates the template" do
      template = template_fixture()
      assert {:ok, %Template{} = template} = Builder.update_template(template, @update_attrs)
      assert template.name == "some updated name"
    end

    test "update_template/2 with invalid data returns error changeset" do
      template = template_fixture()
      assert {:error, %Ecto.Changeset{}} = Builder.update_template(template, @invalid_attrs)
      assert template == Builder.get_template!(template.id)
    end

    test "delete_template/1 deletes the template" do
      template = template_fixture()
      assert {:ok, %Template{}} = Builder.delete_template(template)
      assert_raise Ecto.NoResultsError, fn -> Builder.get_template!(template.id) end
    end

    test "change_template/1 returns a template changeset" do
      template = template_fixture()
      assert %Ecto.Changeset{} = Builder.change_template(template)
    end
  end

  describe "prototypes" do
    alias Exmud.Builder.Prototype

    @valid_attrs %{name: "some name"}
    @update_attrs %{name: "some updated name"}
    @invalid_attrs %{name: nil}

    def prototype_fixture(attrs \\ %{}) do
      {:ok, prototype} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Builder.create_prototype()

      prototype
    end

    test "list_prototypes/0 returns all prototypes" do
      prototype = prototype_fixture()
      assert Builder.list_prototypes() == [prototype]
    end

    test "get_prototype!/1 returns the prototype with given id" do
      prototype = prototype_fixture()
      assert Builder.get_prototype!(prototype.id) == prototype
    end

    test "create_prototype/1 with valid data creates a prototype" do
      assert {:ok, %Prototype{} = prototype} = Builder.create_prototype(@valid_attrs)
      assert prototype.name == "some name"
    end

    test "create_prototype/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Builder.create_prototype(@invalid_attrs)
    end

    test "update_prototype/2 with valid data updates the prototype" do
      prototype = prototype_fixture()
      assert {:ok, %Prototype{} = prototype} = Builder.update_prototype(prototype, @update_attrs)
      assert prototype.name == "some updated name"
    end

    test "update_prototype/2 with invalid data returns error changeset" do
      prototype = prototype_fixture()
      assert {:error, %Ecto.Changeset{}} = Builder.update_prototype(prototype, @invalid_attrs)
      assert prototype == Builder.get_prototype!(prototype.id)
    end

    test "delete_prototype/1 deletes the prototype" do
      prototype = prototype_fixture()
      assert {:ok, %Prototype{}} = Builder.delete_prototype(prototype)
      assert_raise Ecto.NoResultsError, fn -> Builder.get_prototype!(prototype.id) end
    end

    test "change_prototype/1 returns a prototype changeset" do
      prototype = prototype_fixture()
      assert %Ecto.Changeset{} = Builder.change_prototype(prototype)
    end
  end
end
