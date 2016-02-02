defmodule Eden.Repo.Migrations.CreatePlayerToken do
  use Ecto.Migration

  def change do
    create table(:player_tokens, primary_key: false) do
      add :id, :uuid, primary_key: true, default: fragment("uuid_generate_v4()")
      add :player_id, :integer
      add :type, :string
      add :token, :string, default: fragment("uuid_generate_v4()")
      add :expiry, :string

      timestamps
    end

    create index(:player_tokens, [:player_id])
    create index(:player_tokens, [:token, :expiry])
  end
end
