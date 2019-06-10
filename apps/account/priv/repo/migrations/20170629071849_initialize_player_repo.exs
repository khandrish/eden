defmodule Exmud.Player.Repo.Migrations.InitializePlayerRepo do
  use Ecto.Migration

  def change do
    create table(:account) do
      add(:username, :string)
      add(:nickname, :string)
      add(:email, :string)
      add(:email_verified, :boolean)
      add(:password, :string)
    end

    create(unique_index(:account, [:username]))
    create(unique_index(:account, [:nickname]))
    create(unique_index(:account, [:email]))
    create(index(:account, [:email_verified]))

    create table(:account_token) do
      add(:token, :string)
      add(:type, :string)
      add(:expiry, :timestamptz)
      add(:account_id, references(:account, on_delete: :delete_all))
    end

    create(unique_index(:account_token, [:token]))
    create(index(:account_token, [:type]))
    create(index(:account_token, [:expiry]))
    create(index(:account_token, [:account_id]))
  end
end
