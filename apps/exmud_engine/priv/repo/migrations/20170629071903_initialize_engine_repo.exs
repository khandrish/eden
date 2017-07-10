defmodule Exmud.DB.Repo.EngineRepo.Migrations.InitializeEngineRepo do
  use Ecto.Migration

  def change do
    # Tables which stand on their own and have no relationships
    create table(:system) do
      add :key, :string
      add :state, :binary
    end
    create unique_index(:system, [:key])

    # Tables related to game objects
    create table(:object) do
      add :date_created, :timestamptz
      add :key, :string
    end
    create index(:object, [:key])
    create index(:object, [:date_created])

    create table(:component) do
      add :object_id, references(:object, [on_delete: :delete_all])
      add :component, :binary
    end
    create index(:component, [:component])
    create index(:component, [:object_id])
    create unique_index(:component, [:object_id, :component])

    create table(:attribute) do
      add :attribute, :string
      add :component_id, references(:component, [on_delete: :delete_all])
      add :data, :binary
    end
    create index(:attribute, [:attribute])
    create index(:attribute, [:component_id])
    create unique_index(:attribute, [:attribute, :component_id])

    create table(:callback) do
      add :object_id, references(:object, [on_delete: :delete_all])
      add :string, :string
      add :callback_module, :binary
    end
    create index(:callback, [:callback_module])
    create index(:callback, [:object_id])
    create index(:callback, [:string])
    create unique_index(:callback, [:object_id, :string])

    create table(:command_set) do
      add :object_id, references(:object, [on_delete: :delete_all])
      add :callback_module, :binary

      timestamps()
    end
    create index(:command_set, [:object_id])
    create unique_index(:command_set, [:callback_module, :object_id])

    create table(:lock) do
      add :object_id, references(:object, [on_delete: :delete_all])
      add :type, :string
      add :definition, :string
    end
    create index(:lock, [:object_id])
    create index(:lock, [:type])

    create table(:relationship) do
      add :object_id, references(:object, [on_delete: :delete_all])
      add :relationship, :string
      add :data, :binary
      add :subject_id, references(:object, [on_delete: :delete_all])
    end
    create index(:relationship, [:object_id])
    create index(:relationship, [:relationship])
    create index(:relationship, [:subject_id])
    create unique_index(:relationship, [:object_id, :relationship, :subject_id])

    create table(:script) do
      add :object_id, references(:object, [on_delete: :delete_all])
      add :key, :string
      add :state, :binary
    end
    create index(:script, [:key])
    create index(:script, [:object_id])
    create unique_index(:script, [:object_id, :key])

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
