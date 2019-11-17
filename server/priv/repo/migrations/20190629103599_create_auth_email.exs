defmodule Exmud.Repo.Migrations.CreateAuthEmail do
  use Ecto.Migration

  def change do
    create table(:auth_emails, primary_key: false) do
      add :email, :binary, primary_key: true
      add :email_verified, :boolean, default: false, null: false
      add :hash, :binary, null: false
      add :player_id, references(:players, on_delete: :delete_all, type: :binary_id)

      timestamps()
    end

    create index(:auth_emails, [:email_verified])
    create index(:auth_emails, [:email])
    create index(:auth_emails, [:hash])
    create index(:auth_emails, [:player_id])
  end
end
