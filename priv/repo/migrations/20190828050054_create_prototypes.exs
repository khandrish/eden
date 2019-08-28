defmodule Exmud.Repo.Migrations.CreatePrototypes do
  use Ecto.Migration

  def change do
    create table(:prototypes) do
      add :name, :string

      timestamps()
    end

    create index(:prototypes, [:name])
  end
end
