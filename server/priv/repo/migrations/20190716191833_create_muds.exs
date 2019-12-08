defmodule Exmud.Repo.Migrations.CreateEngines do
  use Ecto.Migration

  def change do
    create table(:muds, primary_key: false) do
      add :description, :string
      add :id, :binary_id, primary_key: true
      add :name, :string
      add :player_id, references(:players, on_delete: :nilify_all, type: :binary_id)
      add :slug, :string

      timestamps()
    end

    create unique_index(:muds, [:name])
    create index(:muds, [:player_id])
    create unique_index(:muds, [:slug])
  end
end
