defmodule Eden.Repo.Migrations.CreatePlayersTable do
  use Ecto.Migration

  def change do
    create table(:players, primary_key: false) do
      add :id, :binary_id, primary_key: true, default: fragment("uuid_generate_v4()")
      add :login, :string
      add :name, :string
      add :last_name_change, :datetime
      add :email, :string
      add :hash, :string
      add :email_verified, :boolean, default: false
      add :last_login, :datetime
      add :failed_login_attempts, :integer, default: 0

      timestamps
    end

    create unique_index(:players, [:login])
    create unique_index(:players, [:email])
  end
end