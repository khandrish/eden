defmodule Exmud.Repo.Migrations.CreateTemplates do
  use Ecto.Migration

  def change do
    create table(:templates) do
      add :name, :string
      add :description, :string
      add :slug, :string
      add :category_id, references(:categories, on_delete: :nilify_all)
      add :mud_id, references(:categories, on_delete: :delete_all)

      timestamps()
    end

    create index(:templates, [:category_id])
    create unique_index(:templates, [:name])
  end
end
