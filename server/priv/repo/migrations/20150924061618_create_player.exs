defmodule Eden.Repo.Migrations.CreatePlayer do
  use Ecto.Migration

  def change do
    create table(:players) do
      add :login, :string
      add :name, :string
      add :last_name_change, :datetime
      add :email, :string
      add :hash, :binary
      add :email_verified, :boolean, default: false
      add :last_login, :datetime
      add :failed_login_attempts, :integer, default: 0
      add :login_lock, :map
      add :email_verification_token, :string
      add :password_reset_token, :string

      timestamps
    end

    create unique_index(:players, [:login])

  end
end