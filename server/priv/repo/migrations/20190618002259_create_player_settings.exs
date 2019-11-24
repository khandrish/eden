defmodule Exmud.Repo.Migrations.CreatePlayerSettings do
  use Ecto.Migration

  def change do
    create table(:player_settings, primary_key: false) do
      add :player_id, :binary_id, references(:players), primary_key: true
      add :developer_feature_on, :boolean, default: false, null: false

      timestamps()
    end

    create unique_index(:player_settings, [:player_id])
    create index(:player_settings, [:developer_feature_on])
  end
end
