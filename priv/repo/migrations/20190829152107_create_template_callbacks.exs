defmodule Exmud.Repo.Migrations.CreateTemplateCallbacks do
  use Ecto.Migration

  def change do
    create table(:template_callbacks) do
      add :config, :map
      add :priority, :integer
      add :template_id, references(:templates, on_delete: :delete_all)
      add :callback_id, references(:callbacks, on_delete: :delete_all)

      timestamps()
    end

    create index(:template_callbacks, [:template_id])
    create index(:template_callbacks, [:callback_id])

    create unique_index(:template_callbacks, [:callback_id, :template_id],
             name: "template_callbacks_callback_index"
           )
  end
end
