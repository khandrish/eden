defmodule Exmud.Repo.Migrations.CreateTemplateCallbacks do
  use Ecto.Migration

  def change do
    create table(:template_callbacks) do
      add :default_config, :map
      add :template_id, references(:templates, on_delete: :delete_all)
      add :simulation_callback_id, references(:simulation_callbacks, on_delete: :delete_all)

      timestamps()
    end

    create index(:template_callbacks, [:template_id])
    create index(:template_callbacks, [:simulation_callback_id])

    create unique_index(:template_callbacks, [:simulation_callback_id, :template_id],
             name: "template_callback_index"
           )
  end
end
