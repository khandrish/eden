defmodule Exmud.DB.Repo.EngineRepo.Migrations.InitializeEngineRepo do
  use Ecto.Migration

  def change do
    # Tables which stand on their own and have no relationships
    create table(:system) do
      add :name, :string
      add :state, :binary
    end
    create unique_index(:system, [:name])

    # Tables related to game objects
    create table(:object) do
      add :date_created, :timestamptz
      add :key, :string
    end
    create index(:object, [:key])
    create index(:object, [:date_created])

    create table(:component) do
      add :object_id, references(:object, [on_delete: :delete_all])
      add :component, :string
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
      add :key, :string
      add :name, :string
    end
    create index(:callback, [:object_id])
    create index(:callback, [:key])
    create unique_index(:callback, [:object_id, :key])

    create table(:command_set) do
      add :object_id, references(:object, [on_delete: :delete_all])
      add :command_set, :binary

      timestamps()
    end
    create index(:command_set, [:object_id])
    create unique_index(:command_set, [:command_set, :object_id])

    create table(:lock) do
      add :object_id, references(:object, [on_delete: :delete_all])
      add :type, :string
      add :definition, :string
    end
    create index(:lock, [:object_id])
    create index(:lock, [:type])

    create table(:relationship) do
      add :from_id, references(:object, [on_delete: :delete_all])
      add :relationship, :string
      add :data, :binary
      add :to_id, references(:object, [on_delete: :delete_all])
    end
    create index(:relationship, [:from_id])
    create index(:relationship, [:relationship])
    create index(:relationship, [:to_id])
    create unique_index(:relationship, [:from_id, :relationship, :to_id])

    create table(:script) do
      add :name, :string
      add :object_id, references(:object, [on_delete: :delete_all])
      add :state, :binary
    end
    create index(:script, [:name])
    create index(:script, [:object_id])
    create unique_index(:script, [:object_id, :name])

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
