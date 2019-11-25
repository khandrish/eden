defmodule Exmud.Repo.Migrations.CreateAuthEmail do
  use Ecto.Migration

  def change do
    create table(:auth_emails, primary_key: false) do
      add :email, :binary
      add :email_verified, :boolean, default: false, null: false
      add :hash, :binary, null: false
      add :player_id, references(:players, on_delete: :delete_all, type: :binary_id), primary_key: true

      timestamps()
    end

    create index(:auth_emails, [:email_verified])
    create unique_index(:auth_emails, [:email])
    create index(:auth_emails, [:hash])
  end
end
