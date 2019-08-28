defmodule Exmud.Repo.Migrations.CreateTemplates do
  use Ecto.Migration

  def change do
    create table(:templates) do
      add :name, :binary
      add :mud_id, references(:muds, on_delete: :delete_all)
      add :template_type_id, references(:template_types, on_delete: :nilify_all)
      add :template_category_id, references(:template_categories, on_delete: :nilify_all)

      timestamps()
    end

    create index(:templates, [:mud_id])
    create index(:templates, [:template_type_id])
    create index(:templates, [:template_category_id])
    create unique_index(:templates, [:name, :mud_id], name: "templates_name_index")
  end
end
