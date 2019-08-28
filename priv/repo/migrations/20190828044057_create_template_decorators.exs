defmodule Exmud.Repo.Migrations.CreateTemplateDecorators do
  use Ecto.Migration

  def change do
    create table(:template_decorators) do
      add :template_id, references(:templates, on_delete: :delete_all)
      add :decorator_id, references(:decorators, on_delete: :delete_all)

      timestamps()
    end

    create index(:template_decorators, [:template_id])
    create index(:template_decorators, [:decorator_id])

    create unique_index(:template_decorators, [:decorator_id, :template_id],
             name: "template_decorators_template_index"
           )
  end
end
