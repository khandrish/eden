defmodule Exmud.EngineTest do
  use Exmud.DataCase

  alias Exmud.Engine

  describe "simulations" do
    alias Exmud.Engine.Simulation

    @valid_attrs %{name: "some name", status: "some status"}
    @update_attrs %{name: "some updated name", status: "some updated status"}
    @invalid_attrs %{name: nil, status: nil}

    def simulation_fixture(attrs \\ %{}) do
      {:ok, simulation} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Engine.create_simulation()

      simulation
    end

    test "list_simulations/0 returns all simulations" do
      simulation = simulation_fixture()
      assert Engine.list_simulations() == [simulation]
    end

    test "get_simulation!/1 returns the simulation with given id" do
      simulation = simulation_fixture()
      assert Engine.get_simulation!(simulation.id) == simulation
    end

    test "create_simulation/1 with valid data creates a simulation" do
      assert {:ok, %Simulation{} = simulation} = Engine.create_simulation(@valid_attrs)
      assert simulation.name == "some name"
      assert simulation.status == "some status"
    end

    test "create_simulation/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Engine.create_simulation(@invalid_attrs)
    end

    test "update_simulation/2 with valid data updates the simulation" do
      simulation = simulation_fixture()

      assert {:ok, %Simulation{} = simulation} =
               Engine.update_simulation(simulation, @update_attrs)

      assert simulation.name == "some updated name"
      assert simulation.status == "some updated status"
    end

    test "update_simulation/2 with invalid data returns error changeset" do
      simulation = simulation_fixture()
      assert {:error, %Ecto.Changeset{}} = Engine.update_simulation(simulation, @invalid_attrs)
      assert simulation == Engine.get_simulation!(simulation.id)
    end

    test "delete_simulation/1 deletes the simulation" do
      simulation = simulation_fixture()
      assert {:ok, %Simulation{}} = Engine.delete_simulation(simulation)
      assert_raise Ecto.NoResultsError, fn -> Engine.get_simulation!(simulation.id) end
    end

    test "change_simulation/1 returns a simulation changeset" do
      simulation = simulation_fixture()
      assert %Ecto.Changeset{} = Engine.change_simulation(simulation)
    end
  end

  describe "callbacks" do
    alias Exmud.Engine.Callbacks

    @valid_attrs %{
      default_config: "some default_config",
      module: "some module",
      type: "some type"
    }
    @update_attrs %{
      default_config: "some updated default_config",
      module: "some updated module",
      type: "some updated type"
    }
    @invalid_attrs %{default_config: nil, module: nil, type: nil}

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
      assert callbacks.default_config == "some default_config"
      assert callbacks.module == "some module"
      assert callbacks.type == "some type"
    end

    test "create_callbacks/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Engine.create_callbacks(@invalid_attrs)
    end

    test "update_callbacks/2 with valid data updates the callbacks" do
      callbacks = callbacks_fixture()
      assert {:ok, %Callbacks{} = callbacks} = Engine.update_callbacks(callbacks, @update_attrs)
      assert callbacks.default_config == "some updated default_config"
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

  describe "simulation_callbacks" do
    alias Exmud.Engine.SimulationCallback

    @valid_attrs %{default_config: "some default_config"}
    @update_attrs %{default_config: "some updated default_config"}
    @invalid_attrs %{default_config: nil}

    def simulation_callback_fixture(attrs \\ %{}) do
      {:ok, simulation_callback} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Engine.create_simulation_callback()

      simulation_callback
    end

    test "list_simulation_callbacks/0 returns all simulation_callbacks" do
      simulation_callback = simulation_callback_fixture()
      assert Engine.list_simulation_callbacks() == [simulation_callback]
    end

    test "get_simulation_callback!/1 returns the simulation_callback with given id" do
      simulation_callback = simulation_callback_fixture()
      assert Engine.get_simulation_callback!(simulation_callback.id) == simulation_callback
    end

    test "create_simulation_callback/1 with valid data creates a simulation_callback" do
      assert {:ok, %SimulationCallback{} = simulation_callback} =
               Engine.create_simulation_callback(@valid_attrs)

      assert simulation_callback.default_config == "some default_config"
    end

    test "create_simulation_callback/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Engine.create_simulation_callback(@invalid_attrs)
    end

    test "update_simulation_callback/2 with valid data updates the simulation_callback" do
      simulation_callback = simulation_callback_fixture()

      assert {:ok, %SimulationCallback{} = simulation_callback} =
               Engine.update_simulation_callback(simulation_callback, @update_attrs)

      assert simulation_callback.default_config == "some updated default_config"
    end

    test "update_simulation_callback/2 with invalid data returns error changeset" do
      simulation_callback = simulation_callback_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Engine.update_simulation_callback(simulation_callback, @invalid_attrs)

      assert simulation_callback == Engine.get_simulation_callback!(simulation_callback.id)
    end

    test "delete_simulation_callback/1 deletes the simulation_callback" do
      simulation_callback = simulation_callback_fixture()
      assert {:ok, %SimulationCallback{}} = Engine.delete_simulation_callback(simulation_callback)

      assert_raise Ecto.NoResultsError, fn ->
        Engine.get_simulation_callback!(simulation_callback.id)
      end
    end

    test "change_simulation_callback/1 returns a simulation_callback changeset" do
      simulation_callback = simulation_callback_fixture()
      assert %Ecto.Changeset{} = Engine.change_simulation_callback(simulation_callback)
    end
  end

  describe "templates" do
    alias Exmud.Engine.Template

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
    alias Exmud.Engine.TemplateCallback

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
      assert {:ok, %TemplateCallback{} = template_callback} = Engine.create_template_callback(@valid_attrs)
      assert template_callback.default_args == "some default_args"
    end

    test "create_template_callback/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Engine.create_template_callback(@invalid_attrs)
    end

    test "update_template_callback/2 with valid data updates the template_callback" do
      template_callback = template_callback_fixture()
      assert {:ok, %TemplateCallback{} = template_callback} = Engine.update_template_callback(template_callback, @update_attrs)
      assert template_callback.default_args == "some updated default_args"
    end

    test "update_template_callback/2 with invalid data returns error changeset" do
      template_callback = template_callback_fixture()
      assert {:error, %Ecto.Changeset{}} = Engine.update_template_callback(template_callback, @invalid_attrs)
      assert template_callback == Engine.get_template_callback!(template_callback.id)
    end

    test "delete_template_callback/1 deletes the template_callback" do
      template_callback = template_callback_fixture()
      assert {:ok, %TemplateCallback{}} = Engine.delete_template_callback(template_callback)
      assert_raise Ecto.NoResultsError, fn -> Engine.get_template_callback!(template_callback.id) end
    end

    test "change_template_callback/1 returns a template_callback changeset" do
      template_callback = template_callback_fixture()
      assert %Ecto.Changeset{} = Engine.change_template_callback(template_callback)
    end
  end
end
