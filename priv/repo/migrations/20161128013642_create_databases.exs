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

    create table(:attribute) do
      add :oid, references(:object, [on_delete: :delete_all])
      add :key, :string
      add :data, :binary
    end
    create index(:attribute, [:key])
    create unique_index(:attribute, [:oid, :key])

    create table(:callback) do
      add :oid, references(:object, [on_delete: :delete_all])
      add :string, :string
      add :module, :binary
    end
    create index(:callback, [:string])
    create index(:callback, [:module])
    create unique_index(:callback, [:oid, :string])

    create table(:command_set) do
      add :oid, references(:object, [on_delete: :delete_all])
      add :key, :string
    end
    create index(:callback, [:oid])
    create unique_index(:command_set, [:key, :oid])

    create table(:lock) do
      add :oid, references(:object, [on_delete: :delete_all])
      add :type, :string
      add :definition, :string
    end
    create index(:lock, [:type])
    create index(:lock, [:oid])

    create table(:relationship) do
      add :object, references(:object, [on_delete: :delete_all])
      add :relationship, :string
      add :subject, references(:object, [on_delete: :delete_all])
    end
    create index(:relationship, [:relationship])
    create index(:relationship, [:subject])
    create unique_index(:relationship, [:object, :relationship, :subject])

    create table(:script) do
      add :oid, references(:object, [on_delete: :delete_all])
      add :key, :string
      add :state, :binary
    end
    create index(:script, [:key])
    create unique_index(:script, [:oid, :key])

    create table(:tag) do
      add :category, :string
      add :oid, references(:object, [on_delete: :delete_all])
      add :key, :string
    end
    create index(:tag, [:key])
    create index(:tag, [:category])
    create unique_index(:tag, [:oid, :key, :category])
  end
end
