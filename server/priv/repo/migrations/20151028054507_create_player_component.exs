defmodule Eden.Repo.Migrations.CreatePlayerComponent do
  use Ecto.Migration

  def change do
    create table(:player_components) do
      add :login, :string
      add :last_login, :string
      add :failed_login_attempts, :string
      add :hash, :string
      add :email_verified, :string
      add :login_lock, :string
      add :email, :string
      add :email_verification_token, :string
      add :name, :string
      add :last_name_change, :string
      add :entity_id, references(:entities)

      timestamps
    end

    create index(:player_components, [:entity_id])
    create unique_index(:player_components, [:login])
  end
end
