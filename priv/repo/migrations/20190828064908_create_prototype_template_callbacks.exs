defmodule Exmud.Repo.Migrations.CreatePrototypeTemplateCallbacks do
  use Ecto.Migration

  def change do
    create table(:prototype_template_callbacks) do
      add :default_config, :map
      add :callback_id, references(:callbacks, on_delete: :delete_all)
      add :prototype_template_id, references(:prototype_templates, on_delete: :delete_all)

      timestamps()
    end

    create index(:prototype_template_callbacks, [:callback_id])
    create index(:prototype_template_callbacks, [:prototype_template_id])
  end
end
