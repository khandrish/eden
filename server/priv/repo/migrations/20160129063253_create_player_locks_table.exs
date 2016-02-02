defmodule Eden.Repo.Migrations.PlayerLock do
  use Ecto.Migration

  def change do
    create table(:player_locks, primary_key: false) do
      add :id, :uuid, primary_key: true, default: fragment("uuid_generate_v4()")
      add :player_id, :integer
      add :type, :string
      add :reason, :string
      add :duration, :string
      add :created_by, :integer
      add :last_modified_by, :integer
      timestamps
    end

    create index(:player_locks, [:created_by])
    create index(:player_locks, [:last_modified_by])
    create index(:player_locks, [:player_id])
    create index(:player_locks, [:type])
  end
end
