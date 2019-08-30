defmodule Exmud.Repo.Migrations.CreatePlayers do
  use Ecto.Migration

  def change do
    create table(:players) do
      timestamps(type: :utc_datetime_usec)
    end
  end
end
