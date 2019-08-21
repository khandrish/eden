defmodule Exmud.Repo.Migrations.CreateMuds do
  use Ecto.Migration

  def change do
    create table(:muds) do
      add :name, :string
      add :status, :string

      timestamps()
    end

    create unique_index(:muds, [:name])
    create index(:muds, [:status])
  end
end
