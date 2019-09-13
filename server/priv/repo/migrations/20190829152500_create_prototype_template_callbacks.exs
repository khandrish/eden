defmodule Exmud.Repo.Migrations.CreatePrototypeTemplateCallbacks do
  use Ecto.Migration

  def change do
    create table(:prototype_template_callbacks, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :config, :map
      add :prototype_template_id, references(:prototype_templates, on_delete: :delete_all, type: :binary_id)
      add :callback_id, references(:callbacks, on_delete: :delete_all, type: :binary_id)

      timestamps()
    end

    create index(:prototype_template_callbacks, [:prototype_template_id])

    create unique_index(:prototype_template_callbacks, [:callback_id, :prototype_template_id],
             name: "prototype_template_callbacks_callback_index"
           )
  end
end
