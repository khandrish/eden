defmodule Eden.Repo.Migrations.CreatePlayerToken do
  use Ecto.Migration

  def change do
    create table(:player_tokens) do
      add :player_id, :integer
      add :type, :string
      add :token, :string
      add :expiry, :string

      timestamps
    end

    create index(:player_tokens, [:player_id])
    create index(:player_tokens, [:token, :expiry])
  end
end
