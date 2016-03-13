defmodule Eden.Repo.Migrations.CreatePlayerLocksTable do
  use Ecto.Migration

  def change do
    create table(:player_locks, primary_key: false) do
      add :id, :binary_id, primary_key: true, default: fragment("uuid_generate_v4()")
      add :player_id, references(:players, type: :binary_id)
      add :type, :string
      add :reason, :string
      add :expiry, :datetime
      timestamps
    end

    create index(:player_locks, [:expiry])
    create index(:player_locks, [:inserted_at])
    create index(:player_locks, [:player_id])
    create index(:player_locks, [:type])
    create index(:player_locks, [:updated_at])
  end
end
