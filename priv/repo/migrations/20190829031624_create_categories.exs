defmodule Exmud.Repo.Migrations.CreateCategories do
  use Ecto.Migration

  def change do
    create table(:categories) do
      add :name, :string
      add :description, :string
      add :slug, :string
      add :mud_id, references(:categories, on_delete: :delete_all)

      timestamps()
    end

    alter table(:categories) do
      add :category_id, references(:categories, on_delete: :nilify_all)
    end

    create index(:categories, [:category_id])
    create unique_index(:categories, [:name])
  end
end
