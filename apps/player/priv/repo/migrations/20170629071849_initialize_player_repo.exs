defmodule Exmud.Player.Repo.Migrations.InitializePlayerRepo do
  use Ecto.Migration

  def change do
    create table(:player) do
      add :email, :string
      add :email_verified, :boolean
      add :login, :string
      add :password, :string
      add :nickname, :string
      add :failed_login_attempts, :integer
      add :last_login, :timestamptz
      add :last_nickname_change, :timestamptz
    end
    create index(:player, [:email])
    create index(:player, [:nickname])
    create unique_index(:player, [:login])
  end
end
