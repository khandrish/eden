defmodule Exmud.Repo.Migrations.CreateTemplateCallbacks do
  use Ecto.Migration

  def change do
    create table(:template_callbacks) do
      add :default_config, :map
      add :template_id, references(:templates, on_delete: :delete_all)
      add :callback_id, references(:callbacks, on_delete: :delete_all)

      timestamps()
    end

    create index(:template_callbacks, [:template_id])
    create index(:template_callbacks, [:callback_id])
  end
end
