defmodule Exmud.Repo.Migrations.CreateDatabases do
  use Ecto.Migration

  def change do
    create table(:player) do
      add :key, :string
    end
    create unique_index(:player, [:key])
    
    create table(:command_set) do
      add :key, :string
    end
    create unique_index(:command_set, [:key])
    
    create table(:game_object) do
      add :key, :string
      add :location, references(:game_object)
      add :home, references(:game_object)
      add :date_created, :datetime
      add :type, :string
    end
    
    create table(:system) do
      add :key, :string
      add :state, :binary
      add :callback, :binary
    end
    create unique_index(:system, [:key])
    
    create table(:player_data) do
      add :player_id, references(:player, [on_delete: :delete_all])
      add :key, :string
      add :value, :binary
    end
    create unique_index(:player_data, [:player_id, :key])
    
    create table(:player_command_set) do
      add :command_set_id, references(:command_set, [on_delete: :delete_all])
      add :player_id, references(:player, [on_delete: :delete_all])
    end
    create unique_index(:player_command_set, [:command_set_id, :player_id])
    
    create table(:game_object_command_set) do
      add :command_set_id, references(:command_set, [on_delete: :delete_all])
      add :game_object_id, references(:game_object, [on_delete: :delete_all])
    end
    create unique_index(:game_object_command_set, [:command_set_id, :game_object_id])
    
    create table(:alias) do
      add :game_object_id, references(:game_object, [on_delete: :delete_all])
      add :alias, :string
    end
    create unique_index(:alias, [:game_object_id, :alias])
    
    create table(:lock) do
      add :game_object_id, references(:game_object, [on_delete: :delete_all])
      add :type, :string
      add :definition, :string
    end
    
    create table(:tag) do
      add :game_object_id, references(:game_object, [on_delete: :delete_all])
      add :tag, :string
    end
    create unique_index(:tag, [:game_object_id, :tag])
    
    create table(:game_object_data) do
      add :game_object_id, references(:game_object, [on_delete: :delete_all])
      add :key, :string
      add :value, :binary
    end
    create unique_index(:game_object_data, [:game_object_id, :key])
  end
end
