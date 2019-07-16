defmodule Exmud.Repo.Migrations.CreateSimulations do
  use Ecto.Migration

  def change do
    create table(:simulations) do
      add :name, :string
      add :status, :string

      timestamps()
    end

    create unique_index(:simulations, [:name])
    create index(:simulations, [:status])
  end
end
