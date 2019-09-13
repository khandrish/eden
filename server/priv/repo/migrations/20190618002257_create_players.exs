defmodule Exmud.Repo.Migrations.CreatePlayers do
  use Ecto.Migration

  def change do
    create table(:players, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :status, :string
      
      timestamps(type: :utc_datetime_usec)
    end

    create index(:players, [:status])
  end
end
