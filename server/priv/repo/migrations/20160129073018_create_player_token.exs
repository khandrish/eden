defmodule Eden.Repo.Migrations.CreatePlayerTokensTable do
  use Ecto.Migration

  def change do
    create table(:player_tokens, primary_key: false) do
      add :id, :binary_id, primary_key: true, default: fragment("uuid_generate_v4()")
      add :player_id, references(:players, type: :binary_id)
      add :type, :string
      add :token, :string

      timestamps
    end

    create index(:player_tokens, [:player_id])
    create index(:player_tokens, [:token])
    create index(:player_tokens, [:type])
  end
end
