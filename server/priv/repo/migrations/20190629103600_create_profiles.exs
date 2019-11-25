defmodule Exmud.Repo.Migrations.CreateProfiles do
  use Ecto.Migration

  def change do
    create table(:profiles, primary_key: false) do
      add :nickname, :string, null: true
      add :slug, :string, null: true
      add :email, :string, null: true
      add :email_verified, :boolean, default: false, null: false
      add :player_id, references(:players, on_delete: :delete_all, type: :binary_id), primary_key: true

      timestamps()
    end

    create unique_index(:profiles, [:nickname])
    create unique_index(:profiles, [:slug])
    create unique_index(:profiles, [:email])
  end
end
