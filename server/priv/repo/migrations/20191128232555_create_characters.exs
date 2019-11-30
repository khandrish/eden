defmodule Exmud.Repo.Migrations.CreateCharacters do
  use Ecto.Migration

  def change do
    create table(:characters, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :mud_id, references(:muds, on_delete: :nothing, type: :binary_id)
      add :name, :string
      add :player_id, references(:players, on_delete: :nothing, type: :binary_id)
      add :slug, :string, null: true

      timestamps()
    end

    create index(:characters, [:player_id])
    create index(:characters, [:mud_id])
    create index(:characters, [:name])
    create index(:characters, [:slug])
    create unique_index(:characters, [:name, :mud_id])
    create unique_index(:characters, [:slug, :mud_id])
  end
end
