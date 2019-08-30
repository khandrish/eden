defmodule Exmud.Repo.Migrations.CreateProfiles do
  use Ecto.Migration

  def change do
    create table(:profiles) do
      add :nickname, :string
      add :slug, :string
      add :email, :string
      add :email_verified, :boolean, default: false, null: false
      add :tos_accepted, :boolean, default: false, null: false
      add :player_id, references(:players, on_delete: :delete_all)

      timestamps()
    end

    create unique_index(:profiles, [:nickname])
    create unique_index(:profiles, [:email])
    create index(:profiles, [:tos_accepted])
    create index(:profiles, [:player_id])
  end
end
