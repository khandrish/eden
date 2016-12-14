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
    create table(:game_object) do
      add :date_created, :datetime
      add :key, :string
    end
    create index(:game_object, [:key])
    create index(:game_object, [:date_created])
    
    create table(:attribute) do
      add :oid, references(:game_object, [on_delete: :delete_all])
      add :name, :string
      add :data, :binary
    end
    create index(:attribute, [:name])
    create unique_index(:attribute, [:oid, :name])
    
    create table(:callback) do
      add :oid, references(:game_object, [on_delete: :delete_all])
      add :callback, :string
      add :key, :string
    end
    create index(:callback, [:callback])
    create index(:callback, [:key])
    create unique_index(:callback, [:oid, :callback])
    
    create table(:command_set) do
      add :oid, references(:game_object, [on_delete: :delete_all])
      add :key, :string
    end
    create unique_index(:command_set, [:key])
    
    create table(:lock) do
      add :oid, references(:game_object, [on_delete: :delete_all])
      add :type, :string
      add :definition, :string
    end
    create index(:lock, [:type])
    create index(:lock, [:oid])
    
    create table(:relationship) do
      add :object, references(:game_object, [on_delete: :delete_all])
      add :relationship, :string
      add :subject, references(:game_object, [on_delete: :delete_all])
    end
    create index(:relationship, [:relationship])
    create index(:relationship, [:subject])
    create unique_index(:relationship, [:object, :relationship, :subject])
    
    create table(:script) do
      add :oid, references(:game_object, [on_delete: :delete_all])
      add :key, :string
      add :state, :binary
    end
    create index(:script, [:key])
    create unique_index(:script, [:oid, :key])
    
    create table(:tag) do
      add :category, :string
      add :oid, references(:game_object, [on_delete: :delete_all])
      add :tag, :string
      add :type, :string
    end
    create index(:tag, [:tag]) 
    create index(:tag, [:type])
  end
end
