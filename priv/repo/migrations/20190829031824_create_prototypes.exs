defmodule Exmud.Repo.Migrations.CreatePrototypes do
  use Ecto.Migration

  def change do
    create table(:prototypes) do
      add :name, :string
      add :description, :string
      add :slug, :string
      add :category_id, references(:categories, on_delete: :nilify_all)
      add :mud_id, references(:categories, on_delete: :delete_all)

      timestamps()
    end

    create index(:prototypes, [:mud_id])
    create index(:prototypes, [:category_id])
    create unique_index(:prototypes, [:name, :mud_id], name: "prototypes_name_index")
  end
end
