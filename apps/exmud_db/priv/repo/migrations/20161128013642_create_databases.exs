defmodule Exmud.Repo.Migrations.CreateDatabases do
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
      add :oid, references(:object, [on_delete: :delete_all])
      add :component, :binary
    end
    create index(:component, [:component])
    create index(:component, [:oid])
    create unique_index(:component, [:oid, :component])

    create table(:component_data) do
      add :attribute, :string
      add :component_id, references(:component, [on_delete: :delete_all])
      add :data, :binary
    end
    create index(:component_data, [:attribute])
    create index(:component_data, [:component_id])
    create unique_index(:component_data, [:attribute, :component_id])

    create table(:callback) do
      add :oid, references(:object, [on_delete: :delete_all])
      add :string, :string
      add :callback_module, :binary
    end
    create index(:callback, [:callback_module])
    create index(:callback, [:oid])
    create index(:callback, [:string])
    create unique_index(:callback, [:oid, :string])

    create table(:command_set) do
      add :oid, references(:object, [on_delete: :delete_all])
      add :callback_module, :binary

      timestamps()
    end
    create index(:command_set, [:oid])
    create unique_index(:command_set, [:callback_module, :oid])

    create table(:lock) do
      add :oid, references(:object, [on_delete: :delete_all])
      add :type, :string
      add :definition, :string
    end
    create index(:lock, [:oid])
    create index(:lock, [:type])

    create table(:relationship) do
      add :object, references(:object, [on_delete: :delete_all])
      add :relationship, :string
      add :data, :binary
      add :subject, references(:object, [on_delete: :delete_all])
    end
    create index(:relationship, [:object])
    create index(:relationship, [:relationship])
    create index(:relationship, [:subject])
    create unique_index(:relationship, [:object, :relationship, :subject])

    create table(:script) do
      add :oid, references(:object, [on_delete: :delete_all])
      add :key, :string
      add :state, :binary
    end
    create index(:script, [:key])
    create index(:script, [:oid])
    create unique_index(:script, [:oid, :key])

    create table(:tag) do
      add :category, :string
      add :oid, references(:object, [on_delete: :delete_all])
      add :key, :string
    end
    create index(:tag, [:category])
    create index(:tag, [:key])
    create index(:tag, [:oid])
    create unique_index(:tag, [:oid, :key, :category])
  end
end