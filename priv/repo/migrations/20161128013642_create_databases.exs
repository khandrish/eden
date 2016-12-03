defmodule Exmud.Repo.Migrations.CreateDatabases do
  use Ecto.Migration

  def change do
    create table(:game_object) do
      add :key, :string
      add :date_created, :datetime
    end
    create index(:game_object, [:key])
    create index(:game_object, [:date_created])
    
    create table(:system) do
      add :key, :string
      add :state, :binary
    end
    create unique_index(:system, [:key])
    
    create table(:command_set) do
      add :oid, references(:game_object, [on_delete: :delete_all])
      add :key, :string
    end
    create unique_index(:command_set, [:key])
    
    create table(:home) do
      add :oid, references(:game_object, [on_delete: :delete_all])
      add :home, references(:game_object, [on_delete: :delete_all])
    end
    create index(:home, [:home])
    create unique_index(:home, [:oid, :home])
    
    create table(:location) do
      add :oid, references(:game_object, [on_delete: :delete_all])
      add :location, references(:game_object, [on_delete: :delete_all])
    end
    create index(:location, [:location])
    create unique_index(:location, [:oid, :location])
    
    create table(:alias) do
      add :oid, references(:game_object, [on_delete: :delete_all])
      add :alias, :string
    end
    create index(:alias, [:alias])
    create unique_index(:alias, [:oid, :alias])
    
    create table(:lock) do
      add :oid, references(:game_object, [on_delete: :delete_all])
      add :type, :string
      add :definition, :string
    end
    create index(:lock, [:type])
    create index(:lock, [:oid])
    
    create table(:tag) do
      add :oid, references(:game_object, [on_delete: :delete_all])
      add :tag, :string
    end
    create index(:tag, [:tag])
    create unique_index(:tag, [:oid, :tag])
    
    create table(:attribute) do
      add :oid, references(:game_object, [on_delete: :delete_all])
      add :name, :string
      add :data, :binary
    end
    create index(:attribute, [:name])
    create unique_index(:attribute, [:oid, :name])
  end
end
