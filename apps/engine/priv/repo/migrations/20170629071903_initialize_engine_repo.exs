defmodule Exmud.DB.Repo.EngineRepo.Migrations.InitializeEngineRepo do
  use Ecto.Migration

  def change do
    create table(:engine) do
      add :initialized, :boolean
    end

    create table(:object) do
      add :date_created, :timestamptz
      add :key, :string
    end
    create index(:object, [:key])
    create index(:object, [:date_created])

    create table(:system) do
      add :callback_module, :binary
      add :state, :binary
    end
    create unique_index(:system, [:callback_module])

    create table(:component) do
      add :object_id, references(:object, [on_delete: :delete_all])
      add :callback_module, :binary
    end
    create index(:component, [:callback_module])
    create index(:component, [:object_id])
    create unique_index(:component, [:object_id, :callback_module], name: :component_object_id_callback_module_index)

    create table(:attribute) do
      add :name, :string
      add :component_id, references(:component, [on_delete: :delete_all])
      add :value, :binary
    end
    create index(:attribute, [:name])
    create index(:attribute, [:component_id])
    create unique_index(:attribute, [:name, :component_id])

    create table(:command_set) do
      add :object_id, references(:object, [on_delete: :delete_all])
      add :callback_module, :binary
      add :config, :binary
      add :visibility, :string

      timestamps()
    end
    create index(:command_set, [:object_id])
    create index(:command_set, [:visibility])
    create unique_index(:command_set, [:callback_module, :object_id], name: :command_set_callback_module_index)

    create table(:lock) do
      add :object_id, references(:object, [on_delete: :delete_all])
      add :access_type, :string
      add :callback_module, :binary
      add :config, :binary
    end
    create index(:lock, [:object_id])
    create index(:lock, [:access_type])
    create unique_index(:lock, [:object_id, :access_type], name: :lock_object_id_access_type_index)

    create table(:link) do
      add :from_id, references(:object, [on_delete: :delete_all])
      add :type, :string
      add :state, :binary
      add :to_id, references(:object, [on_delete: :delete_all])
    end
    create index(:link, [:from_id])
    create index(:link, [:type])
    create index(:link, [:to_id])
    create unique_index(:link, [:from_id, :type, :to_id])

    create table(:script) do
      add :callback_module, :binary
      add :object_id, references(:object, [on_delete: :delete_all])
      add :state, :binary
    end
    create index(:script, [:callback_module])
    create index(:script, [:object_id])
    create unique_index(:script, [:object_id, :callback_module])

    create table(:tag) do
      add :category, :string
      add :object_id, references(:object, [on_delete: :delete_all])
      add :tag, :string
    end
    create index(:tag, [:category])
    create index(:tag, [:tag])
    create index(:tag, [:object_id])
    create unique_index(:tag, [:object_id, :tag, :category])
  end
end
