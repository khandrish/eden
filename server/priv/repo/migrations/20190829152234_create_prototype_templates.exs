defmodule Exmud.Repo.Migrations.CreatePrototypeTemplates do
  use Ecto.Migration

  def change do
    create table(:prototype_templates, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :template_id, references(:templates, on_delete: :delete_all, type: :binary_id)
      add :prototype_id, references(:prototypes, on_delete: :delete_all, type: :binary_id)

      timestamps()
    end

    create index(:prototype_templates, [:template_id])
    create index(:prototype_templates, [:prototype_id])

    create unique_index(:prototype_templates, [:template_id, :prototype_id],
             name: "prototype_templates_template_index"
           )
  end
end
