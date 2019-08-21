defmodule Exmud.Repo.Migrations.CreateTemplates do
  use Ecto.Migration

  def change do
    create table(:templates) do
      add :name, :binary
      add :simulation_id, references(:simulations, on_delete: :delete_all)

      timestamps()
    end

    create index(:templates, [:simulation_id])
    create unique_index(:templates, [:name])
  end
end
