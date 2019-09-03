defmodule Exmud.EngineTest do
  use Exmud.DataCase

  alias Exmud.Engine

  describe "muds" do
    alias Exmud.Engine.Mud

    @valid_attrs %{name: "some name", status: "some status"}
    @update_attrs %{name: "some updated name", status: "some updated status"}
    @invalid_attrs %{name: nil, status: nil}

    def mud_fixture(attrs \\ %{}) do
      {:ok, mud} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Engine.create_mud()

      mud
    end

    test "list_muds/0 returns all muds" do
      mud = mud_fixture()
      assert Engine.list_muds() == [mud]
    end

    test "get_mud!/1 returns the mud with given id" do
      mud = mud_fixture()
      assert Engine.get_mud!(mud.id) == mud
    end

    test "create_mud/1 with valid data creates a mud" do
      assert {:ok, %Engine{} = mud} = Engine.create_mud(@valid_attrs)
      assert mud.name == "some name"
      assert mud.status == "some status"
    end

    test "create_mud/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Engine.create_mud(@invalid_attrs)
    end

    test "update_mud/2 with valid data updates the mud" do
      mud = mud_fixture()

      assert {:ok, %Engine{} = mud} = Engine.update_mud(mud, @update_attrs)

      assert mud.name == "some updated name"
      assert mud.status == "some updated status"
    end

    test "update_mud/2 with invalid data returns error changeset" do
      mud = mud_fixture()
      assert {:error, %Ecto.Changeset{}} = Engine.update_mud(mud, @invalid_attrs)
      assert mud == Engine.get_mud!(mud.id)
    end

    test "delete_mud/1 deletes the mud" do
      mud = mud_fixture()
      assert {:ok, %Engine{}} = Engine.delete_mud(mud)
      assert_raise Ecto.NoResultsError, fn -> Engine.get_mud!(mud.id) end
    end

    test "change_mud/1 returns a mud changeset" do
      mud = mud_fixture()
      assert %Ecto.Changeset{} = Engine.change_mud(mud)
    end
  end

  describe "callbacks" do
    alias Exmud.Builder.Callbacks

    @valid_attrs %{
      config: "some config",
      module: "some module",
      type: "some type"
    }
    @update_attrs %{
      config: "some updated config",
      module: "some updated module",
      type: "some updated type"
    }
    @invalid_attrs %{config: nil, module: nil, type: nil}

    def callbacks_fixture(attrs \\ %{}) do
      {:ok, callbacks} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Engine.create_callbacks()

      callbacks
    end

    test "list_callbacks/0 returns all callbacks" do
      callbacks = callbacks_fixture()
      assert Engine.list_callbacks() == [callbacks]
    end

    test "get_callbacks!/1 returns the callbacks with given id" do
      callbacks = callbacks_fixture()
      assert Engine.get_callbacks!(callbacks.id) == callbacks
    end

    test "create_callbacks/1 with valid data creates a callbacks" do
      assert {:ok, %Callbacks{} = callbacks} = Engine.create_callbacks(@valid_attrs)
      assert callbacks.config == "some config"
      assert callbacks.module == "some module"
      assert callbacks.type == "some type"
    end

    test "create_callbacks/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Engine.create_callbacks(@invalid_attrs)
    end

    test "update_callbacks/2 with valid data updates the callbacks" do
      callbacks = callbacks_fixture()
      assert {:ok, %Callbacks{} = callbacks} = Engine.update_callbacks(callbacks, @update_attrs)
      assert callbacks.config == "some updated config"
      assert callbacks.module == "some updated module"
      assert callbacks.type == "some updated type"
    end

    test "update_callbacks/2 with invalid data returns error changeset" do
      callbacks = callbacks_fixture()
      assert {:error, %Ecto.Changeset{}} = Engine.update_callbacks(callbacks, @invalid_attrs)
      assert callbacks == Engine.get_callbacks!(callbacks.id)
    end

    test "delete_callbacks/1 deletes the callbacks" do
      callbacks = callbacks_fixture()
      assert {:ok, %Callbacks{}} = Engine.delete_callbacks(callbacks)
      assert_raise Ecto.NoResultsError, fn -> Engine.get_callbacks!(callbacks.id) end
    end

    test "change_callbacks/1 returns a callbacks changeset" do
      callbacks = callbacks_fixture()
      assert %Ecto.Changeset{} = Engine.change_callbacks(callbacks)
    end
  end

  describe "mud_callbacks" do
    alias Exmud.Engine.MudCallback

    @valid_attrs %{config: "some config"}
    @update_attrs %{config: "some updated config"}
    @invalid_attrs %{config: nil}

    def mud_callback_fixture(attrs \\ %{}) do
      {:ok, mud_callback} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Engine.create_mud_callback()

      mud_callback
    end

    test "list_mud_callbacks/0 returns all mud_callbacks" do
      mud_callback = mud_callback_fixture()
      assert Engine.list_mud_callbacks() == [mud_callback]
    end

    test "get_mud_callback!/1 returns the mud_callback with given id" do
      mud_callback = mud_callback_fixture()
      assert Engine.get_mud_callback!(mud_callback.id) == mud_callback
    end

    test "create_mud_callback/1 with valid data creates a mud_callback" do
      assert {:ok, %EngineCallback{} = mud_callback} = Engine.create_mud_callback(@valid_attrs)

      assert mud_callback.config == "some config"
    end

    test "create_mud_callback/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Engine.create_mud_callback(@invalid_attrs)
    end

    test "update_mud_callback/2 with valid data updates the mud_callback" do
      mud_callback = mud_callback_fixture()

      assert {:ok, %EngineCallback{} = mud_callback} =
               Engine.update_mud_callback(mud_callback, @update_attrs)

      assert mud_callback.config == "some updated config"
    end

    test "update_mud_callback/2 with invalid data returns error changeset" do
      mud_callback = mud_callback_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Engine.update_mud_callback(mud_callback, @invalid_attrs)

      assert mud_callback == Engine.get_mud_callback!(mud_callback.id)
    end

    test "delete_mud_callback/1 deletes the mud_callback" do
      mud_callback = mud_callback_fixture()
      assert {:ok, %EngineCallback{}} = Engine.delete_mud_callback(mud_callback)

      assert_raise Ecto.NoResultsError, fn ->
        Engine.get_mud_callback!(mud_callback.id)
      end
    end

    test "change_mud_callback/1 returns a mud_callback changeset" do
      mud_callback = mud_callback_fixture()
      assert %Ecto.Changeset{} = Engine.change_mud_callback(mud_callback)
    end
  end

  describe "templates" do
    alias Exmud.Template.Template

    @valid_attrs %{name: "some name"}
    @update_attrs %{name: "some updated name"}
    @invalid_attrs %{name: nil}

    def template_fixture(attrs \\ %{}) do
      {:ok, template} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Engine.create_template()

      template
    end

    test "list_templates/0 returns all templates" do
      template = template_fixture()
      assert Engine.list_templates() == [template]
    end

    test "get_template!/1 returns the template with given id" do
      template = template_fixture()
      assert Engine.get_template!(template.id) == template
    end

    test "create_template/1 with valid data creates a template" do
      assert {:ok, %Template{} = template} = Engine.create_template(@valid_attrs)
      assert template.name == "some name"
    end

    test "create_template/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Engine.create_template(@invalid_attrs)
    end

    test "update_template/2 with valid data updates the template" do
      template = template_fixture()
      assert {:ok, %Template{} = template} = Engine.update_template(template, @update_attrs)
      assert template.name == "some updated name"
    end

    test "update_template/2 with invalid data returns error changeset" do
      template = template_fixture()
      assert {:error, %Ecto.Changeset{}} = Engine.update_template(template, @invalid_attrs)
      assert template == Engine.get_template!(template.id)
    end

    test "delete_template/1 deletes the template" do
      template = template_fixture()
      assert {:ok, %Template{}} = Engine.delete_template(template)
      assert_raise Ecto.NoResultsError, fn -> Engine.get_template!(template.id) end
    end

    test "change_template/1 returns a template changeset" do
      template = template_fixture()
      assert %Ecto.Changeset{} = Engine.change_template(template)
    end
  end

  describe "template_callbacks" do
    alias Exmud.Template.TemplateCallback

    @valid_attrs %{default_args: "some default_args"}
    @update_attrs %{default_args: "some updated default_args"}
    @invalid_attrs %{default_args: nil}

    def template_callback_fixture(attrs \\ %{}) do
      {:ok, template_callback} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Engine.create_template_callback()

      template_callback
    end

    test "list_template_callbacks/0 returns all template_callbacks" do
      template_callback = template_callback_fixture()
      assert Engine.list_template_callbacks() == [template_callback]
    end

    test "get_template_callback!/1 returns the template_callback with given id" do
      template_callback = template_callback_fixture()
      assert Engine.get_template_callback!(template_callback.id) == template_callback
    end

    test "create_template_callback/1 with valid data creates a template_callback" do
      assert {:ok, %TemplateCallback{} = template_callback} =
               Engine.create_template_callback(@valid_attrs)

      assert template_callback.default_args == "some default_args"
    end

    test "create_template_callback/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Engine.create_template_callback(@invalid_attrs)
    end

    test "update_template_callback/2 with valid data updates the template_callback" do
      template_callback = template_callback_fixture()

      assert {:ok, %TemplateCallback{} = template_callback} =
               Engine.update_template_callback(template_callback, @update_attrs)

      assert template_callback.default_args == "some updated default_args"
    end

    test "update_template_callback/2 with invalid data returns error changeset" do
      template_callback = template_callback_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Engine.update_template_callback(template_callback, @invalid_attrs)

      assert template_callback == Engine.get_template_callback!(template_callback.id)
    end

    test "delete_template_callback/1 deletes the template_callback" do
      template_callback = template_callback_fixture()
      assert {:ok, %TemplateCallback{}} = Engine.delete_template_callback(template_callback)

      assert_raise Ecto.NoResultsError, fn ->
        Engine.get_template_callback!(template_callback.id)
      end
    end

    test "change_template_callback/1 returns a template_callback changeset" do
      template_callback = template_callback_fixture()
      assert %Ecto.Changeset{} = Engine.change_template_callback(template_callback)
    end
  end

  describe "decorators" do
    alias Exmud.Engine.Decorator

    @valid_attrs %{category: "some category", name: "some name", type: "some type"}
    @update_attrs %{
      category: "some updated category",
      name: "some updated name",
      type: "some updated type"
    }
    @invalid_attrs %{category: nil, name: nil, type: nil}

    def decorator_fixture(attrs \\ %{}) do
      {:ok, decorator} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Engine.create_decorator()

      decorator
    end

    test "list_decorators/0 returns all decorators" do
      decorator = decorator_fixture()
      assert Engine.list_decorators() == [decorator]
    end

    test "get_decorator!/1 returns the decorator with given id" do
      decorator = decorator_fixture()
      assert Engine.get_decorator!(decorator.id) == decorator
    end

    test "create_decorator/1 with valid data creates a decorator" do
      assert {:ok, %Decorator{} = decorator} = Engine.create_decorator(@valid_attrs)
      assert decorator.category == "some category"
      assert decorator.name == "some name"
      assert decorator.type == "some type"
    end

    test "create_decorator/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Engine.create_decorator(@invalid_attrs)
    end

    test "update_decorator/2 with valid data updates the decorator" do
      decorator = decorator_fixture()
      assert {:ok, %Decorator{} = decorator} = Engine.update_decorator(decorator, @update_attrs)
      assert decorator.category == "some updated category"
      assert decorator.name == "some updated name"
      assert decorator.type == "some updated type"
    end

    test "update_decorator/2 with invalid data returns error changeset" do
      decorator = decorator_fixture()
      assert {:error, %Ecto.Changeset{}} = Engine.update_decorator(decorator, @invalid_attrs)
      assert decorator == Engine.get_decorator!(decorator.id)
    end

    test "delete_decorator/1 deletes the decorator" do
      decorator = decorator_fixture()
      assert {:ok, %Decorator{}} = Engine.delete_decorator(decorator)
      assert_raise Ecto.NoResultsError, fn -> Engine.get_decorator!(decorator.id) end
    end

    test "change_decorator/1 returns a decorator changeset" do
      decorator = decorator_fixture()
      assert %Ecto.Changeset{} = Engine.change_decorator(decorator)
    end
  end
end