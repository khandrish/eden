defmodule Exmud.Repo.Migrations.CreateTemplateTypes do
  use Ecto.Migration

  def change do
    create table(:template_types) do
      add :name, :string
      add :mud_id, references(:muds, on_delete: :delete_all)

      timestamps()
    end

    create unique_index(:template_types, [:mud_id, :name], name: "template_types_mud_index")
  end
end
