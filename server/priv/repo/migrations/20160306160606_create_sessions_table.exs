defmodule Eden.Repo.Migrations.CreateSessionsTable do
  use Ecto.Migration

  def change do
    create table(:sessions, primary_key: false) do
      add :id, :uuid, primary_key: true, default: fragment("uuid_generate_v4()")
      add :db_data, :binary
      add :expiry, :datetime
      add :token, :binary_id
    end
  end
end