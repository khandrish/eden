defmodule Exmud.Repo.Migrations.CreateCategories do
  use Ecto.Migration

  def change do
    create table(:categories, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string
      add :description, :string
      add :slug, :string
      add :mud_id, references(:categories, on_delete: :delete_all, type: :binary_id)

      timestamps()
    end

    alter table(:categories) do
      add :category_id, references(:categories, on_delete: :nilify_all, type: :binary_id)
    end

    create index(:categories, [:category_id])
    create unique_index(:categories, [:name])
  end
end
