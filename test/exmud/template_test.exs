defmodule Exmud.TemplateTest do
  use Exmud.DataCase

  alias Exmud.Template

  describe "template_categories" do
    alias Exmud.Template.TemplateCategory

    @valid_attrs %{name: "some name"}
    @update_attrs %{name: "some updated name"}
    @invalid_attrs %{name: nil}

    def template_category_fixture(attrs \\ %{}) do
      {:ok, template_category} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Template.create_template_category()

      template_category
    end

    test "list_template_categories/0 returns all template_categories" do
      template_category = template_category_fixture()
      assert Template.list_template_categories() == [template_category]
    end

    test "get_template_category!/1 returns the template_category with given id" do
      template_category = template_category_fixture()
      assert Template.get_template_category!(template_category.id) == template_category
    end

    test "create_template_category/1 with valid data creates a template_category" do
      assert {:ok, %TemplateCategory{} = template_category} = Template.create_template_category(@valid_attrs)
      assert template_category.name == "some name"
    end

    test "create_template_category/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Template.create_template_category(@invalid_attrs)
    end

    test "update_template_category/2 with valid data updates the template_category" do
      template_category = template_category_fixture()
      assert {:ok, %TemplateCategory{} = template_category} = Template.update_template_category(template_category, @update_attrs)
      assert template_category.name == "some updated name"
    end

    test "update_template_category/2 with invalid data returns error changeset" do
      template_category = template_category_fixture()
      assert {:error, %Ecto.Changeset{}} = Template.update_template_category(template_category, @invalid_attrs)
      assert template_category == Template.get_template_category!(template_category.id)
    end

    test "delete_template_category/1 deletes the template_category" do
      template_category = template_category_fixture()
      assert {:ok, %TemplateCategory{}} = Template.delete_template_category(template_category)
      assert_raise Ecto.NoResultsError, fn -> Template.get_template_category!(template_category.id) end
    end

    test "change_template_category/1 returns a template_category changeset" do
      template_category = template_category_fixture()
      assert %Ecto.Changeset{} = Template.change_template_category(template_category)
    end
  end

  describe "template_types" do
    alias Exmud.Template.TemplateType

    @valid_attrs %{name: "some name"}
    @update_attrs %{name: "some updated name"}
    @invalid_attrs %{name: nil}

    def template_type_fixture(attrs \\ %{}) do
      {:ok, template_type} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Template.create_template_type()

      template_type
    end

    test "list_template_types/0 returns all template_types" do
      template_type = template_type_fixture()
      assert Template.list_template_types() == [template_type]
    end

    test "get_template_type!/1 returns the template_type with given id" do
      template_type = template_type_fixture()
      assert Template.get_template_type!(template_type.id) == template_type
    end

    test "create_template_type/1 with valid data creates a template_type" do
      assert {:ok, %TemplateType{} = template_type} = Template.create_template_type(@valid_attrs)
      assert template_type.name == "some name"
    end

    test "create_template_type/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Template.create_template_type(@invalid_attrs)
    end

    test "update_template_type/2 with valid data updates the template_type" do
      template_type = template_type_fixture()
      assert {:ok, %TemplateType{} = template_type} = Template.update_template_type(template_type, @update_attrs)
      assert template_type.name == "some updated name"
    end

    test "update_template_type/2 with invalid data returns error changeset" do
      template_type = template_type_fixture()
      assert {:error, %Ecto.Changeset{}} = Template.update_template_type(template_type, @invalid_attrs)
      assert template_type == Template.get_template_type!(template_type.id)
    end

    test "delete_template_type/1 deletes the template_type" do
      template_type = template_type_fixture()
      assert {:ok, %TemplateType{}} = Template.delete_template_type(template_type)
      assert_raise Ecto.NoResultsError, fn -> Template.get_template_type!(template_type.id) end
    end

    test "change_template_type/1 returns a template_type changeset" do
      template_type = template_type_fixture()
      assert %Ecto.Changeset{} = Template.change_template_type(template_type)
    end
  end
end
