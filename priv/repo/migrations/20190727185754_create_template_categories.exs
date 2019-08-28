defmodule Exmud.Repo.Migrations.CreateTemplateCategories do
  use Ecto.Migration

  def change do
    create table(:template_categories) do
      add :name, :string
      add :mud_id, references(:muds, on_delete: :delete_all)

      timestamps()
    end

    create index(:template_categories, [:name])
    create unique_index(:template_categories, [:mud_id, :name],
             name: "template_categories_mud_index"
           )
  end
end
