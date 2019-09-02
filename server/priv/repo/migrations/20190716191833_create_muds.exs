defmodule Exmud.Repo.Migrations.CreateEngines do
  use Ecto.Migration

  def change do
    create table(:muds) do
      add :name, :string
      add :description, :string
      add :slug, :string
      add :status, :string

      timestamps()
    end

    create unique_index(:muds, [:name])
    create index(:muds, [:status])
  end
end
